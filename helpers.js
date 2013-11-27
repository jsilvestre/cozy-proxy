// Generated by CoffeeScript 1.6.3
var bcrypt, randomstring;

randomstring = require("randomstring");

bcrypt = require('bcrypt');

exports.cryptPassword = function(password) {
  var hash, salt;
  salt = bcrypt.genSaltSync(10);
  hash = bcrypt.hashSync(password, salt);
  return {
    hash: hash,
    salt: salt
  };
};

exports.sendResetEmail = function(instance, user, key, callback) {
  var nodemailer, transport;
  nodemailer = require("nodemailer");
  transport = nodemailer.createTransport("SMTP", {});
  return transport.sendMail({
    to: user.email,
    from: "Your Cozy Instance <no-reply@" + instance.domain + ">",
    subject: "[Cozy] Reset password procedure",
    text: "You told to your cozy that you forgot your password. No worry about that, just\ngo to following url and you will be able to set a new one:\n\nhttps://" + instance.domain + "/password/reset/" + key
  }, function(error, response) {
    transport.close();
    return callback(error, response);
  });
};

exports.checkMail = function(email) {
  var re;
  re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return (email != null) && email.length > 0 && re.test(email);
};

exports.hideEmail = function(email) {
  return email.split('@')[0].replace('.', ' '.replace('-', ' '));
};
