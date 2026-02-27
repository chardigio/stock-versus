_ = require 'lodash'
mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
idValidator = require 'mongoose-id-validator'
bcrypt = require 'bcryptjs'

schema = mongoose.Schema
  name: String
  username: String
  password: String
  # portfolios: [{type: mongoose.Schema.Types.ObjectId, ref: 'portfolio'}]

schema.set 'toJSON', transform: (doc, ret, options) ->
  _.pick doc, 'id', 'name', 'username', 'created_at'

schema.pre 'save', (next) ->
  #hash password
  if @isModified 'password' then @password = bcrypt.hashSync @password, bcrypt.genSaltSync 10
  next()

schema.plugin idValidator, message : 'Invalid {PATH}.'
schema.plugin timestamps, createdAt: 'created_at', updatedAt: 'updated_at'

# validation
(schema.path 'name').required yes, 'Name is required.'

(schema.path 'name').validate (val) ->
  val?.length > 1
,'Name is too short.'

(schema.path 'name').validate (val) ->
  val?.length <= 100
, 'Name is too long.'

(schema.path 'username').required yes, 'Username is required.'

(schema.path 'username').validate (val) ->
  val?.length > 1
,'Username is too short.'

(schema.path 'username').validate (val) ->
  val?.length <= 100
, 'Username is too long.'

(schema.path 'password').required yes, 'Password is required.'

# (schema.path 'password').validate (val) ->
#   val?.length > 5
# ,'Passwords must have at least 6 characters.'

(schema.path 'password').validate (val) ->
  val?.length <= 100
,'Password is too long.'

# santization
(schema.path 'name').set (val) -> val.trim()
(schema.path 'username').set (val) -> val.trim()

module.exports = User = mongoose.model 'user', schema
