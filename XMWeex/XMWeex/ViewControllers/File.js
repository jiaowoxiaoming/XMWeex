// { "framework": "Vue" }
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
          
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
          
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
          
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
          
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
          
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
          
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
          
          
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
          
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
          
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
          
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {
       
       var __vue_exports__, __vue_options__
       var __vue_styles__ = []
       
       /* styles */
       __vue_styles__.push(__webpack_require__(1)
                           )
       
       /* script */
       __vue_exports__ = __webpack_require__(2)
       
       /* template */
       var __vue_template__ = __webpack_require__(6)
       __vue_options__ = __vue_exports__ = __vue_exports__ || {}
       if (
           typeof __vue_exports__.default === "object" ||
           typeof __vue_exports__.default === "function"
           ) {
       if (Object.keys(__vue_exports__).some(function (key) { return key !== "default" && key !== "__esModule" })) {console.error("named exports are not supported in *.vue files.")}
       __vue_options__ = __vue_exports__ = __vue_exports__.default
       }
       if (typeof __vue_options__ === "function") {
       __vue_options__ = __vue_options__.options
       }
       __vue_options__.__file = "/Users/apple/Desktop/Weex-APPFrame/Learnweex/src/AppFrame.vue"
       __vue_options__.render = __vue_template__.render
       __vue_options__.staticRenderFns = __vue_template__.staticRenderFns
       __vue_options__._scopeId = "data-v-57e72bd0"
       __vue_options__.style = __vue_options__.style || {}
       __vue_styles__.forEach(function (module) {
                              for (var name in module) {
                              __vue_options__.style[name] = module[name]
                              }
                              })
       if (typeof __register_static_styles__ === "function") {
       __register_static_styles__(__vue_options__._scopeId, __vue_styles__)
       }
       
       module.exports = __vue_exports__
       module.exports.el = 'true'
       new Vue(module.exports)
       
       
/***/ }),
/* 1 */
/***/ (function(module, exports) {
       
       module.exports = {
       "view": {
       "width": 750,
       "height": 1334,
       "backgroundColor": "#ffffff"
       }
       }
       
/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {
       
       'use strict';
       
       Object.defineProperty(exports, "__esModule", {
                             value: true
                             });
       
       var _stringify = __webpack_require__(3);
       
       var _stringify2 = _interopRequireDefault(_stringify);
       
       function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
       
       //
       //
       //
       //
       //
       //
       //
       //
       //
       //
       //
       //
       //
       //
       //
       //
       //
       
       var TabbarItemSelectedImage = 'TabbarItemSelectedImage';
       
       var TabbarItemImage = 'TabbarItemImage';
       
       exports.default = {
       data: function data() {
       return {
       
       tabbarItemsJsonString: (0, _stringify2.default)([{
                                                        //                            标题
                                                        title: '封面',
                                                        //                            没选中字体颜色
                                                        normalTitleColor: '999999',
                                                        //                            选中字体颜色
                                                        selectedTitleColor: 'FF3C00',
                                                        //                            背景颜色
                                                        tintColor: 'FF3C00',
                                                        //                            选中图片
                                                        selectedImage: TabbarItemSelectedImage + '1',
                                                        //                            没选中图片
                                                        image: TabbarItemImage + '1'
                                                        }, {
                                                        title: '发现',
                                                        normalTitleColor: '999999',
                                                        selectedTitleColor: 'FF3C00',
                                                        tintColor: 'FF3C00',
                                                        selectedImage: TabbarItemSelectedImage + '2',
                                                        image: TabbarItemImage + '2'
                                                        }, {
                                                        title: '书桌',
                                                        normalTitleColor: '999999',
                                                        selectedTitleColor: 'FF3C00',
                                                        tintColor: 'FF3C00',
                                                        selectedImage: TabbarItemSelectedImage + '3',
                                                        image: TabbarItemImage + '3'
                                                        }, {
                                                        title: '我',
                                                        normalTitleColor: '999999',
                                                        selectedTitleColor: 'FF3C00',
                                                        tintColor: 'FF3C00',
                                                        selectedImage: TabbarItemSelectedImage + '4',
                                                        image: TabbarItemImage + '4'
                                                        }]),
       viewControllerItemsString: (0, _stringify2.default)([{
                                                            //                            导航栏标题
                                                            title: '',
                                                            //                            透明导航栏的字体颜色
                                                            clearTitleColor: 'ffffff',
                                                            //                            高斯模糊导航栏的字体颜色
                                                            blurTitleColor: '000000',
                                                            //                            左边选项按钮
                                                            leftItemsInfo: [{
                                                                            //                                        原生调取 weex方法名
                                                                            aciton: '',
                                                                            //                                        渲染 按钮的链接  如果以http开头 会渲染网络JSBundle 反之 渲染本地JSBundle
                                                                            itemURL: ''
                                                                            }],
                                                            //                            右边选项按钮
                                                            rightItemsInfo: [{
                                                                             aciton: '',
                                                                             itemURL: 'item.js',
                                                                             //                                        设计图中container的大小
                                                                             frame: '{{0, 0}, {33, 16}}'
                                                                             }],
                                                            //                            把导航栏变成透明的
                                                            clearNavigationBar: true,
                                                            //                            把导航栏隐藏
                                                            hiddenNavgitionBar: false,
                                                            //                            导航栏背景颜色
                                                            navigationBarBackgroundColor: '',
                                                            //                            导航栏背景图片
                                                            navgationBarBackgroundImage: '',
                                                            //                            自定义标题视图的JSBundle地址 如果以http开头 会渲染网络JSBundle 反之 渲染本地JSBundle
                                                            customTitleViewURL: ''
                                                            }, {
                                                            title: '',
                                                            clearTitleColor: '',
                                                            blurTitleColor: '',
                                                            //                            leftItemsInfo:[{aciton:'',itemURL:''}],
                                                            //                            rightItemsInfo:[{aciton:'',itemURL:'item.js',frame:'{{0, 0}, {66, 32}}'}],
                                                            clearNavigationBar: false,
                                                            hiddenNavgitionBar: true,
                                                            navigationBarBackgroundColor: '',
                                                            navgationBarBackgroundImage: '',
                                                            customTitleViewURL: ''
                                                            }, {
                                                            title: '名刊会',
                                                            clearTitleColor: '000000',
                                                            blurTitleColor: '',
                                                            //                            leftItemsInfo:[{aciton:'',itemURL:''}],
                                                            //                            rightItemsInfo:[{aciton:'',itemURL:'item.js',frame:'{{0, 0}, {66, 32}}'}],
                                                            clearNavigationBar: true,
                                                            hiddenNavgitionBar: false,
                                                            navigationBarBackgroundColor: '',
                                                            navgationBarBackgroundImage: '',
                                                            customTitleViewURL: ''
                                                            }, {
                                                            title: '',
                                                            clearTitleColor: '',
                                                            blurTitleColor: '',
                                                            leftItemsInfo: [{ aciton: '', itemURL: '' }],
                                                            rightItemsInfo: [{ aciton: '', itemURL: 'item.js', frame: '{{0, 0}, {33, 16}}' }],
                                                            clearNavigationBar: true,
                                                            hiddenNavgitionBar: false,
                                                            navigationBarBackgroundColor: '',
                                                            navgationBarBackgroundImage: '',
                                                            customTitleViewURL: ''
                                                            }])
       };
       },
       
       methods: {}
       };
       
       module.exports = {
       created: function created() {
       this.$el('AppFrame').focus();
       }
       };
       module.exports = exports['default'];
       
/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {
       
       module.exports = { "default": __webpack_require__(4), __esModule: true };
       
/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {
       
       var core  = __webpack_require__(5)
       , $JSON = core.JSON || (core.JSON = {stringify: JSON.stringify});
       module.exports = function stringify(it){ // eslint-disable-line no-unused-vars
       return $JSON.stringify.apply($JSON, arguments);
       };
       
/***/ }),
/* 5 */
/***/ (function(module, exports) {
       
       var core = module.exports = {version: '2.4.0'};
       if(typeof __e == 'number')__e = core; // eslint-disable-line no-undef
       
/***/ }),
/* 6 */
/***/ (function(module, exports) {
       
       module.exports={render:function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
       return _c('AppFrame', {
                 attrs: {
                 "id": "AppFrame",
                 "tabarItems": _vm.tabbarItemsJsonString,
                 "viewControllerItems": _vm.viewControllerItemsString
                 }
                 })
       },staticRenderFns: []}
       module.exports.render._withStripped = true
       
/***/ })
/******/ ]);
