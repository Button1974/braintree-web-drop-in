'use strict';

var assign = require('./assign').assign;
var find = require('./find-parent-form');
var uuid = require('./uuid');
var DropinError = require('./dropin-error');

function isObjectProperty(key) {
  return key.indexOf('.') > -1;
}

function isArrayProperty(key) {
  return key.indexOf('[') > -1;
}

function make(dataset, config, rootProperty, key) {
  var topLevelKey, subKey;

  config = config || {};

  if (key.indexOf('.') === -1) {
    config[key] = dataset[rootProperty + '.' + key];
  } else {
    topLevelKey = key.split('.')[0];
    subKey = key.substring(topLevelKey.length + 1, key.length);
    config[topLevelKey] = make(dataset, config[topLevelKey], rootProperty + '.' + topLevelKey, subKey);
  }

  return config;
}

function constructSubConfigObject(dataset, rootProperty) {
  var config = {};
  var keys = Object.keys(dataset).filter(function (key) {
    return key.indexOf(rootProperty + '.') > -1;
  }).map(function (key) {
    return key.substring(rootProperty.length + 1, key.length);
  });

  if (keys.length === 0) {
    return null;
  }

  keys.forEach(function (key) {
    make(dataset, config, rootProperty, key);
  });

  return config;
}

function constructSubConfigArray(dataset, rootProperty) {
  var i;
  var config = [];
  var numberOfValues = Object.keys(dataset).filter(function (key) {
    return key.indexOf(rootProperty + '[') > -1;
  }).length;

  if (numberOfValues === 0) {
    return null;
  }

  for (i = 0; i < numberOfValues; i++) {
    config.push(dataset[rootProperty + '[' + i + ']']);
  }

  return config;
}

function applySimpleAttributes(dataset, config, attributes) {
  attributes.filter(function (key) {
    return key !== 'braintreeDropinAuthorization' &&
      !isObjectProperty(key) &&
      !isArrayProperty(key);
  }).forEach(function (key) {
    config[key] = dataset[key];
  });
}

function applyObjectProperties(dataset, config, attributes) {
  var topLevelKeys = attributes.reduce(function (array, key) {
    var topLevelKey;

    if (!isObjectProperty(key)) {
      return array;
    }

    topLevelKey = key.split('.')[0];

    if (array.indexOf(topLevelKey) === -1) {
      array.push(topLevelKey);
    }

    return array;
  }, []);

  topLevelKeys.forEach(function (key) {
    config[key] = constructSubConfigObject(dataset, key);
  });
}

function applyArrayProperties(dataset, config, attributes) {
  var topLevelKeys = attributes.reduce(function (array, key) {
    var topLevelKey;

    if (!isArrayProperty(key)) {
      return array;
    }

    topLevelKey = key.split('[')[0];

    if (array.indexOf(topLevelKey) === -1) {
      array.push(topLevelKey);
    }

    return array;
  }, []);

  topLevelKeys.forEach(function (key) {
    config[key] = constructSubConfigArray(dataset, key);
  });
}

function constructConfigObject(dataset) {
  var config = {};
  var attributes = Object.keys(dataset);

  applySimpleAttributes(dataset, config, attributes);
  applyObjectProperties(dataset, config, attributes);
  applyArrayProperties(dataset, config, attributes);

  return config;
}

function createFromScriptTag(createFunction, scriptTag) {
  var authorization, config, container, form;

  if (!scriptTag) {
    return;
  }

  authorization = scriptTag.getAttribute('data-braintree-dropin-authorization');

  if (!authorization) {
    throw new DropinError('Authorization not found in data-braintree-dropin-authorization attribute');
  }

  container = document.createElement('div');
  container.id = 'braintree-dropin-' + uuid();

  form = find.findParentForm(scriptTag);

  if (!form) {
    throw new DropinError('No form found for script tag integration.');
  }

  form.addEventListener('submit', function (event) {
    event.preventDefault();
  });

  form.insertBefore(container, scriptTag);

  config = constructConfigObject(scriptTag.dataset);

  createFunction(assign({
    authorization: authorization,
    container: container
  }, config), function (createError, instance) {
    if (createError) {
      throw createError;
    }

    form.addEventListener('submit', function () {
      instance.requestPaymentMethod(function (requestPaymentError, payload) {
        var paymentMethodNonce;

        if (requestPaymentError) {
          return;
        }

        paymentMethodNonce = form.querySelector('[name="payment_method_nonce"]');

        if (!paymentMethodNonce) {
          paymentMethodNonce = document.createElement('input');
          paymentMethodNonce.type = 'hidden';
          paymentMethodNonce.name = 'payment_method_nonce';
          form.appendChild(paymentMethodNonce);
        }

        paymentMethodNonce.value = payload.nonce;

        form.submit();
      });
    });
  });
}

module.exports = createFromScriptTag;
