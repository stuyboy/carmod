const jumbotronInstance = React.createElement(
    Jumbotron,
    null,
    React.createElement(
        "h1",
        null,
        "Hello, world!"
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