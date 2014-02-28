DbManager = require './db_manager'

class DeviceManager extends DbManager
    type: 'Device'
    allDevice: []

    update: (callback) ->
        @allDevice = []
        @all (err, devices) =>
            if err then console.log err
            if devices
                for device in devices
                    device = device.value
                    @allDevice[device.login] = device.password
            callback() if callback?

    isAuthenticated: (username, password, callback) ->
        return @allDevice[username]? and @allDevice[username] is password

module.exports = new DeviceManager()
