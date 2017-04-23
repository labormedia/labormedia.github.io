var config = require('./webpack.config');
var webpack = require('webpack');
var ManifestPlugin = require('webpack-manifest-plugin');
var ChunkManifestPlugin = require('chunk-manifest-webpack-plugin');
var WebpackMd5Hash = require('webpack-md5-hash');
var HtmlWebpackPlugin = require('html-webpack-plugin');

config.output.filename = '[name].[chunkhash].min.js';
config.output.chunkFilename = '[name].[chunkhash].min.js';
    
    config.plugins.push(
        new webpack.DefinePlugin({
            MANIFEST: JSON.stringify(require("./src/bundle/build-manifest.json"))
        }),

        new HtmlWebpackPlugin({
            title: 'Main Template',
            template: './src/index.ejs',
            filename: '../index.html'
        }),
        new HtmlWebpackPlugin({
            title: 'Main Template',
            template: './src/index.ejs',
            filename: '../../index.html'
        }),

        new webpack.optimize.UglifyJsPlugin({ 
            minimize: true, 
            sourceMap: false,
            mangle: false
        }),

        new webpack.optimize.CommonsChunkPlugin({
            name: "vendor",
            minChunks: Infinity,
        }),
        new WebpackMd5Hash(),
        new ManifestPlugin({
            fileName: 'build-manifest.json'
        }),
        new ChunkManifestPlugin({
            filename: "chunk-manifest.json",
            manifestVariable: "webpackManifest"
        }),
        new webpack.optimize.OccurrenceOrderPlugin() 
    );

module.exports = config;