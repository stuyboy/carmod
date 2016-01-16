var React = require('react');
var ReactDOM = require('react-dom');
var CarMod = require('./carmod.jsx');
var Jumbo = require('./j2tron2.js').jumbotronInstance;

//alert('what is this cm' + CarMod);
//ReactDOM.render(Jumbo, document.getElementById("downloadButton"));
ReactDOM.render(<CarMod.StoryBlock/>, document.getElementById("stories-block"));
ReactDOM.render(<CarMod.UserBlock/>, document.getElementById("downloadButton"));

//alert($('#cbp-qtrotator'));
//$('#cbp-qtrotator').cbpQTRotator();