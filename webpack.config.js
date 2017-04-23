var path = require('path');

module.exports = {
    devServer: {
        contentBase: "./src",
        hot: true
    },
    entry: './src/index.js',
    output: {
        path: __dirname+'/src',
        filename: 'bundle.js'
    },
    plugins: [
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