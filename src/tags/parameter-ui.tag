<parameter-ui>
  <style scoped>
    position: relative;
    width: 500px;
    height: 500px;
    background: red;
    :scope { display: block }
    /** other tag specific styles **/
    height: 80%;
    width: 80%;
#parameters {
    position: relative;
    width: 500px;
    height: 500px;
    background: red;
    display: block; /* fix for opera and ff */
}
input[type=range][orient=vertical]
{
    writing-mode: bt-lr; /* IE */
    -webkit-appearance: slider-vertical; /* WebKit */
    width: 8px;
    height: 175px;
    padding: 0 5px;
}
input[type=range]
{
    width: 175px;
    height: 8px;
    padding: 0 5px;
}
  </style>
  <script src="src/nouislider/nouislider.js"></script>
  <script>
//- var noUiSlider = require('nouislider');
//-   var slider = document.getElementById('slider');

//- noUiSlider.create(slider, {
//-   start: 40,
//-   connect: "lower",
//-   range: {
//-     min: 0,
//-     max: 100
//-   }
//- });
</script>
  <div id="parent"></div>
  <div id="parameters">
    <h1>UI HUD</h1>
    <input type="range" id="slider" min="1.0" max="10.0" >
    <input type="range" orient="vertical" id="slider" min="1.0" max="10.0" >
  </div>
  <div id="output"> </div>

</parameter-ui>