var React = require('react');
var Parse = require('parse');
var ParseReact = require('parse-react');
var Headhesive = require('headhesive');

var APPLICATION_ID = "riUILiEFVsRGLUquLhPNIkRoIaNoEuglJJXrqXVS";
var JAVASCRIPT_KEY = "zzlpOfn3WLxtRGWcqZAFcj0Rx1eNLgUHmJC6aBIt";

Parse.initialize(APPLICATION_ID, JAVASCRIPT_KEY);

var Activity = Parse.Object.extend("Activity");
var Entity = Parse.Object.extend("Entity");
var Photo = Parse.Object.extend("Photo");
var Story = Parse.Object.extend("Story", {
    authorName: function() {
        return this.get("author").get("displayName");
    }}
);

var Stories = React.createClass({
    mixins: [ParseReact.Mixin],

    observe: function() {
        return {
            descriptions: this.getDescriptionForStory(this.props.storyId)
        };
    },

    handleClick: function(event) {
        alert('what to do now?');
    },

    render: function() {
        var storyLink="/story.html?storyId=" + this.props.storyId;
        var renderType = this.props.renderType;

        return (
            <div id="storyPhotos">
                <Author storyId={this.props.storyId}/>
                {
                    this.data.descriptions.map(function(a, idx) {
                        return (
                            <div id="story-photo-large" key={a.objectId}>
                                <img src={a.photo.image.url()}/>
                                <div id="story-description" className="story-description">
                                    {a.content}
                                </div>
                            </div>
                        );
                    })
                }
            </div>
        );
    },

    getDescriptionForStory: function(storyId) {
        var aQuery = new Parse.Query(Activity);
        var sQuery = new Parse.Query(Story);
        sQuery.get(storyId);
        aQuery.include("photo");
        aQuery.include("story");
        aQuery.include("fromUser");
        aQuery.matchesQuery("story", sQuery);
        aQuery.limit(20);
        return aQuery;
    }
})

var CarInfo = React.createClass({
    mixins: [ParseReact.Mixin],

    observe: function() {
        return {
            car: this.getCarForUser(this.props.userId)
        };
    },

    render: function() {
        return (
            <div id="carWrapper">
            {
                this.data.car.map(function (c, idx) {
                    return (
                        <div id="story-car" className="story-car" key={c.objectId}>{c.year} {c.make} {c.model}</div>
                    );
                })
            }
            </div>
        );
    },

    getCarForUser: function(userId) {
        var uQuery = new Parse.Query(Parse.User);
        var cQuery = new Parse.Query(Entity);
        uQuery.get(userId);
        cQuery.matchesQuery("user", uQuery);
        cQuery.limit(1);
        return cQuery;
    }
})

var Author = React.createClass({
    mixins: [ParseReact.Mixin],

    observe: function() {
        return {
            story: this.getStoryWithAuthor(this.props.storyId)
        };
    },

    render: function() {
        return (
            <div id="story-author" className="story-author">
            {
                this.data.story.map(function(s, idx) {
                    return (
                        <div>
                            <img className="story-author-avatar" src={s.author.profilePictureSmall.url()}/>
                            {s.author.displayName}
                            <CarInfo userId={s.author.objectId}/>
                        </div>
                    );
                })
            }
            </div>
        );
    },

    getStoryWithAuthor: function(storyId) {
        var sQuery = new Parse.Query(Story);
        sQuery.get(storyId);
        sQuery.include("author");
        sQuery.limit(1);
        return sQuery;
    }
})

var StoryPhotos = React.createClass({
    mixins: [ParseReact.Mixin],

    observe: function() {
        return {
            author: this.getAuthorForStory(this.props.storyAuthorId),
            photoUrls: this.getPhotosForStory(this.props.storyId),
            description: this.getDescriptionForStory(this.props.storyId),
            car: this.getCarForStory(this.props.storyAuthorId)
        };
    },

    handleClick: function(event) {
        alert('what to do now?');
    },

    render: function() {
        var title = this.props.storyTitle;
        var authorId = this.props.storyAuthorId;
        var storyLink="/story.html?storyId=" + this.props.storyId;
        var authorLink="/user.html/" + authorId;
        var renderType = this.props.renderType;

        var description = this.data.description.map(function(d, idx) {
            return (
                <div id="story-description" className="story-description" key={d.objectId}>{d.content}</div>
            );
        });

        var car = this.data.car.map(function(c, idx) {
            return (
                <div id="story-car" className="story-car" key={c.objectId}>{c.year} {c.make} {c.model}</div>
            );
        });

        var author = this.data.author.map(function(c, idx) {
            return (
                <div id="story-author" className="story-author" key={c.objectId}>
                    <img className="story-author-avatar" src={c.profilePictureSmall.url()}/>
                    {c.displayName}
                </div>
            );
        });

        return (
            <div id="storyPhotos">
            {
                this.data.photoUrls.map(function(p, idx) {
                    if (renderType == 'thumbnail') {
                        if (idx == 0) {
                            return (
                                <div className="center w-col w-col-3" key={p.objectId}>
                                    <div className="story-album">
                                        <div className="story-thumbnail">
                                            <a className="team-hyper" href={storyLink}>
                                                <img id="thumbnail-img" src={p.image.url()} onClick={this.clickH}/>
                                                <span className="titlehead">
                                                  <h3 className="story-heading">{title}</h3>
                                                  <div className="button small border" href="#">Full Story</div>
                                                </span>
                                            </a>
                                            <div className="story-overlay"></div>
                                        </div>
                                        {author}
                                        {car}
                                        {description}
                                    </div>
                                </div>
                            );
                        }
                    } else {
                        return (
                            <div id="story-photo-large" key={p.objectId}>
                                <img src={p.image.url()}/>
                                {author}
                                {car}
                                {description}
                            </div>
                        );
                   }
                })
            }
            </div>
        );
    },

    getAuthorForStory: function(authorId) {
        var uQuery = new Parse.Query(Parse.User);
        uQuery.get(authorId);
        uQuery.limit(1);
        return uQuery;
    },

    getPhotosForStory: function(storyId) {
        var story = Parse.Object.extend(Story);
        var s = new Story({objectId : storyId});
        var photosRelation = new Parse.Relation(s, 'Photos');
        return photosRelation.query();
    },

    getDescriptionForStory: function(storyId) {
        var aQuery = new Parse.Query(Activity);
        var sQuery = new Parse.Query(Story);
        sQuery.get(storyId);
        aQuery.matchesQuery("story", sQuery);
        aQuery.limit(1);
        return aQuery;
    },

    getCarForStory: function(authorId) {
        var uQuery = new Parse.Query(Parse.User);
        var cQuery = new Parse.Query(Entity);
        uQuery.get(authorId);
        cQuery.matchesQuery("user", uQuery);
        cQuery.limit(1);
        return cQuery;
    }
})

var StoryBlock = React.createClass({
    mixins: [ParseReact.Mixin],

    observe: function() {
        //Get all the stories, display
        var sQuery = new Parse.Query(Story);
        sQuery.include('author');
        if (this.props.storyId) {
            sQuery.get(this.props.storyId);
        }
        return {
            stories: sQuery.descending('createdAt').limit(8)
        };
    },

    render: function() {
        var renderType = this.props.renderType;
        return (
            <div>
            { this.data.stories.map(function(c) {
                return (
                    <div key={c.objectId}>
                        <div id="storyBlock">
                            <StoryPhotos ref="StoryPhotos"
                                         storyId={c.objectId}
                                         storyTitle={c.title}
                                         storyAuthorId={c.author.objectId}
                                         storyAuthor={c.author.displayName}
                                         storyDate={c.createdAt.toString()}
                                         renderType={renderType} />
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
        );
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

var Footer = React.createClass({
    render: function() {
        return (
            <div className="row-back">
                <div className="w-container wrap-normal center">© <strong>Thad & Joe</strong> 2016 - A Work in Progress.</div>
            </div>
        );
    }
});

var Header = React.createClass({
    componentDidMount: function() {
        var options = {
            offset: "#startHeadhesive",
            classes: {
                clone: 'banner--clone',
                stick: 'banner--stick',
                unstick: 'banner--unstick'
            }
        };

        new Headhesive(".banner", options);
    },

    render: function() {
        return (
        <section id="home">
            <div id="banner" className="banner">
                <div className="w-container container">
                    <div className="w-row">
                        <div className="w-col w-col-3 logo">
                            <a href="#"><img className="logo" src="images/app-logo-black.png" alt="CarMod"></img></a>
                        </div>
                        <div className="w-col w-col-9">
                            <div className="w-nav navbar" data-collapse="medium" data-animation="default" data-duration="400" data-contain="1">
                                <div className="w-container nav">
                                    <nav className="w-nav-menu nav-menu" role="navigation">
                                        <a className="w-nav-link menu-li" href="#home">HOME</a>
                                        <a className="w-nav-link menu-li" href="index.html#stories">STORIES</a>
                                        <a className="w-nav-link menu-li filter" data-filter="all" href="index.html#parts">PARTS</a>
                                        <a className="w-nav-link menu-li filter" data-filter=".Tires" href="index.html#parts">TIRES</a>
                                        <a className="w-nav-link menu-li" href="index.html#parts">WHEELS</a>
                                        <a className="w-nav-link menu-li" href="index.html#parts">AUDIO</a>
                                        <a className="w-nav-link menu-li" href="shortcodes.html">CONTACT</a>
                                    </nav>
                                    <div className="w-nav-button">
                                        <div className="w-icon-nav-menu"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="startHeadhesive"></div>
        </section>
            );
    }

});

module.exports.StoryBlock = StoryBlock;
module.exports.UserBlock = UserBlock;
module.exports.PartsBlock = PartsBlock;
module.exports.Stories = Stories;
module.exports.Footer = Footer;
module.exports.Header = Header;
module.exports.Author = Author;