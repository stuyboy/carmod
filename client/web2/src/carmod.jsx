var React = require('react');
var Parse = require('parse');
var ParseReact = require('parse-react');

var APPLICATION_ID = "riUILiEFVsRGLUquLhPNIkRoIaNoEuglJJXrqXVS";
var JAVASCRIPT_KEY = "zzlpOfn3WLxtRGWcqZAFcj0Rx1eNLgUHmJC6aBIt";

Parse.initialize(APPLICATION_ID, JAVASCRIPT_KEY);

var Story = Parse.Object.extend("Story", {
    authorName: function() {
        return this.get("author").get("displayName");
    }}
);

var StoryPhotos = React.createClass({
    mixins: [ParseReact.Mixin],

    observe: function() {
        return {
            photoUrls: this.getPhotosForStory(this.props.storyId)
        };
    },

    handleClick: function(event) {
        alert('what to do now?');
    },

    render: function() {
        var title = this.props.storyTitle;
        var author = this.props.storyAuthor;
        var authorId = this.props.storyAuthorId;
        var storyLink="/story/" + this.props.storyId;
        var authorLink="/user/" + authorId;
        return (
            <div id="storyPhotos">
            {
                this.data.photoUrls.map(function(p, idx) {
                    if (idx == 0) {
                        return (
                            <div className="center w-col w-col-3" key={p.objectId}>
                                <div className="story-album">
                                    <div className="story-thumbnail">
                                        <a className="team-hyper">
                                            <img id="thumbnail-img" src={p.image.url()} onClick={this.clickH}/>
                                            <span className="titlehead">
                                              <h3 className="story-heading">{title}</h3>
                                              <div className="button small border" href="#">Full Story</div>
                                            </span>
                                        </a>
                                        <div className="story-overlay"></div>
                                    </div>
                                    <div className="story-author">
                                        {author}
                                    </div>
                                    <div className="story-car">
                                        2015 Volkswagen GTI
                                    </div>
                                    <div className="story-description">
                                        Bringing some sound to the GTI with the addition of a new exhaust!
                                    </div>
                                </div>
                            </div>
                        );
                    } /* else {
                        return (
                            <div id="storyPhotoSmall" key={p.objectId}>
                               <img src={p.thumbnail.url()}/>
                            </div>
                        );
                    } */
                })
            }
            </div>
        );
    },

    getPhotosForStory: function(storyId) {
        var story = Parse.Object.extend(Story);
        var s = new Story({objectId : storyId});
        var photosRelation = new Parse.Relation(s, 'Photos');
        return photosRelation.query();
    }
})

var StoryBlock = React.createClass({
    mixins: [ParseReact.Mixin],

    observe: function() {
        //Get all the stories, display
        var sQuery = new Parse.Query(Story);
        sQuery.include('author');
        return {
            stories: sQuery.descending('createdAt').limit(8)
        };
    },

    render: function() {
        return (
            <div>
            { this.data.stories.map(function(c) {
                return (
                    <div key={c.objectId}>
                        <div id="storyBlock">
                            <StoryPhotos ref="StoryPhotos" storyId={c.objectId} storyTitle={c.title} storyAuthorId={c.author.objectId} storyAuthor={c.author.displayName} storyDate={c.createdAt.toString()} photoType="main" />
                        </div>
                    </div>
                );
            })
            }
            </div>
        );
    }
})

var UserBlock = React.createClass({
    mixins: [ParseReact.Mixin],

    observe: function () {
        //Get new users, display
        var uQuery = new Parse.Query(Parse.User);
        return {
            users: uQuery.descending('createdAt').limit(5)
        };
    },

    componentDidUpdate(prevProps, prevState) {
        //Start the carousel
        $('#cbp-qtrotator').cbpQTRotator();
    },

    render: function () {
        return (
            <div id="cbp-qtrotator" className="cbp-qtrotator">
                { this.data.users.map(function (c) {
                    return (
                        <div className="cbp-qtcontent" key={c.objectId}>
                            <img src={c.profilePictureMedium.url()} alt="img01" />
                            <blockquote>
                                <p>I love CarMod.  Thad and Joe are studs.</p>
                                <footer>{c.displayName}</footer>
                            </blockquote>
                        </div>
                    );
                  })
                }
            </div>
        );
    }
})

var PartsBlock = React.createClass({
    PARTS_URL: "http://carmod.xyz:8000/parts/latest",
//    PARTS_URL: "http://localhost:8000/parts/latest",

    getInitialState: function() {
        return {
            results: []
        };
    },

    componentDidMount: function() {
        $.get(
            this.PARTS_URL, function(data) {
            if (this.isMounted()) {
                this.setState({
                    parts: data.results
                });
                //alert(JSON.stringify(this.state.parts));
            }
        }.bind(this));
    },

    componentDidUpdate(prevProps, prevState) {
        //Truncate
        $('.parts-model').dotdotdot();
        $('#partsBlock').mixItUp();
    },

    render: function() {
        var parts = this.state.parts;
        if (parts === undefined) {
            return <div/>;
        } else {
            return (
                <div id="partsBlock">
                    {   this.state.parts.map(function (p) {
                        var clsNames = "mix center w-col w-col-3 " + p.classification;
                        return (
                            <div id={p.id} className={clsNames} key={p.id}>
                              <div className="parts-listing">
                                <div className="parts-image">
                                    <img className="auto-vertical" src={p.imageUrl} />
                                </div>
                                <div className="parts-brand">{p.brand}</div>
                                <div className="parts-model">{p.model}</div>
                              </div>
                            </div>
                        );
                    })
                    }
                </div>
            );
        }
    }
})

var ImageUpload = React.createClass({
   render: function() {
       return (
        <div id="imageUpload">
            <form onSubmit={ this.handleSubmit }>
                <input type="file" id="imageFileUpload" ref="file" onChange={ this.changeHandler } />
                <input type="submit" value="Upload"/>
            </form>
        </div>
       );
   },

   handleSubmit: function(e) {
       e.preventDefault();
       var file = this.refs.file.getDOMNode().files[0];
       this.saveFile(file);
   },

   saveFile: function(fileHandle) {
       alert("uploading " + fileHandle);
       var imgFile = new Parse.File(fileHandle.name, fileHandle);
       imgFile.save().then(function() {
           var newPhoto = new Parse.Object("Photo");
           newPhoto.set("file", imgFile);
           newPhoto.save();
       })
   }

});

var CreateUser = React.createClass({
    render: function() {
        return (
            <div id="newUser">
                <form onSubmit={ this.handleSubmit }>
                    <input type="text" ref="username" />
                    <input type="password" ref="password" />
                    <input type="submit" value="Signup"/>
                </form>
            </div>
        )
    },

    handleSubmit: function(e) {
        var username = this.refs.username.value;
        var password = this.refs.password.value;

        var user = new Parse.User();
        user.set("username", username);
        user.set("password", password);
        user.set("displayName", username);
        user.set("email", "test@test.com");

        user.signUp(null, {
            success: function(user) {
                alert("you are signed up!");
            },
            error: function(user, error) {
                alert("Error: " + error.code + " " + error.message);
            }
        }).dispatch();
    }
});

module.exports.StoryBlock = StoryBlock;
module.exports.UserBlock = UserBlock;
module.exports.PartsBlock = PartsBlock;