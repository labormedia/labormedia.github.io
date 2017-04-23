var config = require('./webpack.config');
var webpack = require('webpack');
var ManifestPlugin = require('webpack-manifest-plugin');
var ChunkManifestPlugin = require('chunk-manifest-webpack-plugin');
var WebpackMd5Hash = require('webpack-md5-hash');

config.output.filename = 'bundle.min.js',
    config.plugins.push(new webpack.optimize.UglifyJsPlugin({ minimize: true }));

module.exports = config;