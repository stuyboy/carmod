(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var APPLICATION_ID = "riUILiEFVsRGLUquLhPNIkRoIaNoEuglJJXrqXVS";
var JAVASCRIPT_KEY = "zzlpOfn3WLxtRGWcqZAFcj0Rx1eNLgUHmJC6aBIt";

Parse.initialize(APPLICATION_ID, JAVASCRIPT_KEY);

var Story = Parse.Object.extend("Story", {
    authorName: function () {
        return this.get("author").get("displayName");
    } });

var StoryPhotos = React.createClass({
    displayName: "StoryPhotos",

    mixins: [ParseReact.Mixin],

    observe: function () {
        return {
            photoUrls: this.getPhotosForStory(this.props.storyId)
        };
    },

    render: function () {
        return React.createElement("div", { id: "storyPhotos" }, this.data.photoUrls.map(function (p) {
            return React.createElement("img", { src: p.thumbnail.url() });
        }));
    },

    getPhotosForStory: function (storyId) {
        var story = Parse.Object.extend(Story);
        var s = new Story({ objectId: storyId });
        var photosRelation = new Parse.Relation(s, 'Photos');
        return photosRelation.query();
    }
});

var StoryBlock = React.createClass({
    displayName: "StoryBlock",

    mixins: [ParseReact.Mixin],

    observe: function () {
        //Get all the stories, display
        var sQuery = new Parse.Query(Story);
        sQuery.include('author');
        return {
            stories: sQuery.ascending('createdAt')
        };
    },

    render: function () {
        return React.createElement("ul", null, this.data.stories.map(function (c) {
            return React.createElement("li", null, React.createElement("div", { id: "storyTitle" }, c.title), React.createElement("div", { id: "storyAuthor" }, c.author.displayName, React.createElement(StoryPhotos, { ref: "StoryPhotos", storyId: c.objectId, userId: c.author.objectId })));
        }));
    }
});

var ImageUpload = React.createClass({
    displayName: "ImageUpload",

    render: function () {
        return React.createElement("div", { id: "imageUpload" }, React.createElement("form", { onSubmit: this.handleSubmit }, React.createElement("input", { type: "file", id: "imageFileUpload", ref: "file", onChange: this.changeHandler }), React.createElement("input", { type: "submit", value: "Upload" })));
    },

    handleSubmit: function (e) {
        e.preventDefault();
        var file = this.refs.file.getDOMNode().files[0];
        this.saveFile(file);
    },

    saveFile: function (fileHandle) {
        alert("uploading " + fileHandle);
        var imgFile = new Parse.File(fileHandle.name, fileHandle);
        imgFile.save().then(function () {
            var newPhoto = new Parse.Object("Photo");
            newPhoto.set("file", imgFile);
            newPhoto.save();
        });
    }

});

var CreateUser = React.createClass({
    displayName: "CreateUser",

    render: function () {
        return React.createElement("div", { id: "newUser" }, React.createElement("form", { onSubmit: this.handleSubmit }, React.createElement("input", { type: "text", ref: "username" }), React.createElement("input", { type: "password", ref: "password" }), React.createElement("input", { type: "submit", value: "Signup" })));
    },

    handleSubmit: function (e) {
        var username = this.refs.username.value;
        var password = this.refs.password.value;

        var user = new Parse.User();
        user.set("username", username);
        user.set("password", password);
        user.set("displayName", username);
        user.set("email", "test@test.com");

        user.signUp(null, {
            success: function (user) {
                alert("you are signed up!");
            },
            error: function (user, error) {
                alert("Error: " + error.code + " " + error.message);
            }
        }).dispatch();
    }
});

},{}],2:[function(require,module,exports){
var Jumbotron = ReactBootstrap.Jumbotron;
var Button = ReactBootstrap.Button;

const jumbotronInstance = React.createElement(
    Jumbotron,
    null,
    React.createElement(
        "h1",
        null,
        "Hello, world mang!"
    ),
    React.createElement(
        "p",
        null,
        "This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information."
    ),
    React.createElement(
        "p",
        null,
        React.createElement(
            Button,
            { bsStyle: "primary" },
            "Learn more"
        )
    )
);

ReactDOM.render(jumbotronInstance, document.getElementById("downloadButton"));

},{}]},{},[1,2]);
