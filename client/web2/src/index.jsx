var React = require('react');
var ReactDOM = require('react-dom');
var FBLogin = require('react-facebook-login');
var CarMod = require('./carmod.jsx');
var Initialize = require('./scripts.jsx');
var URI = require('urijs');

//alert('what is this cm' + CarMod);
//ReactDOM.render(Jumbo, document.getElementById("downloadButton"));

if (location.pathname != '/story.html') {
    ReactDOM.render(<CarMod.StoryBlock renderType="thumbnail"/>, document.getElementById("stories-block"));
    ReactDOM.render(<CarMod.UserBlock/>, document.getElementById("user-block"));
    ReactDOM.render(<CarMod.PartsBlock number="8" />, document.getElementById("parts-block"));
} else {
    var storyId = URI().query(true).storyId;
    //ReactDOM.render(<CarMod.StoryBlock renderType="large" storyId={storyId}/>, document.getElementById("stories-block"));
    ReactDOM.render(<CarMod.Stories renderType="large" storyId={storyId}/>, document.getElementById("story-block"));
    ReactDOM.render(<CarMod.PartsBlock number="4" colClass="w-col-6" title="Related Parts" />, document.getElementById("parts-block"));
    ReactDOM.render(<CarMod.Annotations storyId={storyId}/>, document.getElementById("parts-used-block"));
}

ReactDOM.render(<CarMod.Header/>, document.getElementById("header-block"));
ReactDOM.render(<CarMod.Footer/>, document.getElementById("footer-block"));

const responseFacebook = function(response) {
    //console.log(response);
    document.getElementById("fb-login").style.visibility='hidden';
}

ReactDOM.render(<FBLogin appId="671292719680423" autoLoad={true} callback={responseFacebook} textButton="Sign In with Facebook" size="small" />, document.getElementById("fb-login"));



