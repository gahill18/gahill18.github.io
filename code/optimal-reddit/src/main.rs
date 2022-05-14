/* 

If you use this code, please credit Garrett Hill @ gahill18.github.io

 */

extern crate reqwest;

use std::env;
use std::io::Write;
use std::fs::{File,remove_file};

use reqwest::blocking::{Response,Client};
use reqwest::{Error,StatusCode};

use serde::{Serialize, Deserialize};

// Ignore these top 3 structs, they're just wrappers for the posts
#[derive(Debug, Serialize, Deserialize)]
struct Listing {
    kind: String,
    data: ListingData
}

#[derive(Debug, Serialize, Deserialize)]
struct ListingData {
    children: Vec<Child>,
}

#[derive(Debug, Serialize, Deserialize)]
struct Child {
    kind: String,
    data: Post
}

// THIS IS THE STRUCT WE ACTUALLY CARE ABOUT
#[derive(Debug, Serialize, Deserialize)]
struct Post {
    id:    String,
    title: String,
    created_utc: f64,
    score: i32,
    num_comments: i32,
    total_awards_received: i32
    // Additional fields go here
}

// Gets the top posts of the month for the given sub
fn get_top_for_sub(client: &Client, sub: &str) -> Result<Response, Error> {
    // Format the request string
    let get_str =
	format!("https://old.reddit.com/r/{}/top/.json?t=all&?sort=top&t=month", sub);

    // Get the response from reddit
    let response = client.get(get_str)
	.send()?;

    // Make sure the request succeeded
    if response.status() != StatusCode::OK {
	println!("Did not recieve Status 200 OK");
	panic!() // Probably needs better error handling but not necessary right now
    }

    // If you've made it this far, nothing left to do
    Ok(response)
}

// Core logic
fn main() ->  Result<(), Error> {
    // Environment variables execution location, subreddit, path to storefile
    let args: Vec<String> = env::args().collect();
    assert_eq!(args.len(), 3);

    // Get the top listings for the given subreddit
    let client = Client::new();
    let sub    = &args[1];
    let res    = get_top_for_sub(&client, &sub)?;

    // Parse the response for the appropriate nested fields
    let listings = res.json::<Listing>()?;
    let posts = listings.data.children;

    // Get the path to store results in from user
    let path = &args[2];
    let fp = std::path::Path::new(path);

    // If fp already exists, delete it
    if fp.exists() {
	remove_file(fp);
    }

    let mut file = File::create(fp).expect("create failed");

    // Write children to file
    for post in posts {
	let out = format!("{:?}",post);
	file.write_all(out.as_bytes());
    }

    // If you've made it this far, nothing left to do
    Ok(())
}
