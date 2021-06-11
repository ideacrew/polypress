const { environment } = require("@rails/webpacker");
const webpack = require("webpack");
// const CopyPlugin = require("copy-webpack-plugin");
// var path = require("path");
// const { resolve: resolvePath } = require("path");
// const srcPath = resolvePath(__dirname, "src");
// const distPath = resolvePath(__dirname, "dist");

// var resolvePath = require("resolve-path");

environment.plugins.append(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    jQuery: "jquery",
    Popper: ["popper.js", "default"],
  })
);

environment.config.merge({
  externals: {
    jqueryui: "jQuery",
  },
});

// console.log(webpackConfig.output_path);
// console.log(JSON.stringify(environment.config.output.path));
// console.log(
//   JSON.stringify(resolvePath(__dirname, "../../node_modules/ckeditor4/"))
// );

// environment.plugins.append(
//   "CopyPlugin",
//   new CopyPlugin({
//     patterns: [
//       {
//         from: resolvePath(__dirname, "../../node_modules/ckeditor4/"),
//         to: resolvePath(`${environment.config.output.path}/ckeditor`),
//       },
//     ],
//     patterns: [
//       {
//         from:
//           "{config.js,contents.css,styles.js,adapters/**/*,lang/**/*,plugins/**/*,skins/**/*,vendor/**/*}",
//         to: resolvePath(distPath, "ckeditor4"),
//         context: resolvePath(__dirname, "node_modules", "ckeditor4"),
//       },

//       {
//         from: resolvePath(srcPath, "application.js"),
//         to: distPath,
//       },
//     ],
//   })
// );

// process.env.WEBPACK_PUBLIC_PATH = environment.config.output.publicPath;

module.exports = environment;
