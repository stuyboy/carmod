var React = require('react');
var ReactDOM = require('react-dom');
var CarMod = require('./carmod.jsx');
var Initialize = require('./scripts.jsx');
var URI = require('urijs');

//alert('what is this cm' + CarMod);
//ReactDOM.render(Jumbo, document.getElementById("downloadButton"));

if (location.pathname != '/story.html') {
    ReactDOM.render(<CarMod.StoryBlock renderType="thumbnail"/>, document.getElementById("stories-block"));
    ReactDOM.render(<CarMod.UserBlock/>, document.getElementById("user-block"));
    ReactDOM.render(<CarMod.PartsBlock/>, document.getElementById("parts-block"));
} else {
    var storyId = URI().query(true).storyId;
    ReactDOM.render(<CarMod.StoryBlock renderType="large" storyId={storyId}/>, document.getElementById("stories-block"));
}

ReactDOM.render(<CarMod.Header/>, document.getElementById("header-block"));
ReactDOM.render(<CarMod.Footer/>, document.getElementById("footer-block"));
