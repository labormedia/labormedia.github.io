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
//- x = document.getElementById("sliderh");
//- console.log(this.x)
</script>

  <div id="parameters">
    <div>{ number }</div>
    <form action="action_page.php">
      <input type="color" id="gcolor" name="favcolor" value="#ff0000" oninput={ change }>
    </form>
    <input type="range" id="sliderh" min="1.0" max="10.0" step ="0.01" oninput={ change } ></input>
    <input type="range" orient="vertical" id="sliderv" min="1.0" max="10.0" step ="0.01" oninput={ change } >slider</input>
  </div>

  console.log(this.mixin('target').hello)

  change(e) { 
    this.number=[e.target.type,e.target.id,e.target.value];
    
    this.update()
    //- console.log(e.target.type,e.target.id,e.target.value);
    this.mixin('target').target = e.target;
    this.mixin('target').observable.trigger('updated_target', e.target);
  };
  this.number = "Change me!";


</parameter-ui>