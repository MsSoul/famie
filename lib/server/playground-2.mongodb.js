// Select the database to use.
use('famie');

// Create the parent_registration collection and insert a document
db.parent_registration.insertOne({
    email: "parent@example.com",
    username: "parentUsername",
    password: "parentPassword"
});

// Create the child_registration collection and insert a document
db.child_registration.insertOne({
    username: "childUsername",
    password: "childPassword",
    email: "child@example.com",
    day: 1,
    month: 1,
    year: 2020
});

// Create the child_profile collection and insert a document
db.child_profile.insertOne({
    parent_id: ObjectId("60d5f4831d1d3b39e928edc4"),
    child_registration_id: ObjectId("60d5f4831d1d3b39e928edc5"),
    name: "Child Name",
    avatar: "avatar_url",
    device_name: "device_name",
    mac_address: "00:0a:95:9d:68:16"
});

// Create the time_management collection and insert a document
db.time_management.insertOne({
    child_id: ObjectId("60d5f4831d1d3b39e928edc6"),
    start_time: "08:00",
    end_time: "20:00",
    is_allowed: true
});

// Create the app_management collection and insert a document
db.app_management.insertOne({
    child_id: ObjectId("60d5f4831d1d3b39e928edc6"),
    app_name: "App Name",
    package_name: "com.example.app",
    is_allowed: true
});

// Create the app_time_management collection and insert a document
db.app_time_management.insertOne({
    app_id: ObjectId("60d5f4831d1d3b39e928edc7"),
    child_id: ObjectId("60d5f4831d1d3b39e928edc6"),
    start_time: "08:00",
    end_time: "10:00"
});

// Create the admin_registration collection and insert a document
db.admin_registration.insertOne({
    username: "adminUsername",
    email: "admin@example.com",
    password: "adminPassword"
});

// Create the theme_management collection and insert a document
db.theme_management.insertOne({
    background_color: "#FFFFFF",
    font_style: "Arial",
    app_bar_color: "#000000",
    button_color: "#FF0000",
    text_color: "#000000",
    admin_id: ObjectId("60d5f4831d1d3b39e928edc4")
});
