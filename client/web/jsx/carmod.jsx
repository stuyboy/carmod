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

    render: function() {
        var title = this.props.storyTitle;
        var author = this.props.storyAuthor;
        return (
            <div id="storyPhotos">
            {
                this.data.photoUrls.map(function(p, idx) {
                    if (idx == 0) {
                        return (
                            <div id="storyPhotoMain">
                                <img id="storyPhotoImageMain" src={p.image.url()}/>
                                <div id="storyTitle">
                                    {title}
                                </div>
                                <div id="storyAuthor">
                                    {author}
                                </div>
                            </div>
                        );
                    } else {
                        return (
                            <div id="storyPhotoSmall">
                               <img src={p.thumbnail.url()}/>
                            </div>
                        );
                    }
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
            stories: sQuery.ascending('createdAt')
        };
    },

    render: function() {
        return (
            <div>
            { this.data.stories.map(function(c) {
                return (
                    <div>
                        <div id="storyBlock">
                            <StoryPhotos ref="StoryPhotos" storyId={c.objectId} storyTitle={c.title} storyAuthor={c.author.displayName} photoType="main" />
                            <div id="storyDate">
                            {c.createdAt.toString()}
                            </div>
                        </div>
                    </div>
                );
            })
            }
            </div>
        );
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