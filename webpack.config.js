var path = require('path'); 
var webpack = require('webpack');
// var PROD = (process.env.NODE_ENV === 'production')
module.exports = {
    // target: "node",
    devServer: {
        contentBase: "./src",
        hot: true
    },
    entry: {
        bundle: './src/index.js' 
    },
    output: {
        path: path.join(__dirname, 'src/bundle'),
        filename: 'bundle.js'
    },
    plugins: [
        new webpack.ProvidePlugin({
    }),
        new webpack.optimize.UglifyJsPlugin({
            sourceMap: false,
            mangle: false
        })
    ],
    module: {
        loaders:[
            {
                test: /\.js$/,
                loader: 'babel-loader',
                exclude: /node_modules/,
                query: {
                    presets: ['es2015']
                }
            },
            {
                test: /\.tag$/,
                loader: 'tag-loader',
                exclude: /node_modules/
            }
        ]
    }

}