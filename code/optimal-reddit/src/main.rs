/* 

If you use this code, please credit Garrett Hill @ gahill18.github.io

 */

extern crate reqwest;

use std::env;

use reqwest::blocking::{Response,Client};
use reqwest::{Error,StatusCode};

use serde::{Serialize, Deserialize};

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
    score: i32,
    created_utc: f64
}

// Gets the top posts of all time for the given sub
fn get_top_for_sub(client: &Client, sub: &str) -> Result<Response, Error> {
    // Format the request string
    let get_str =
	format!("https://old.reddit.com/r/{}/top/.json?t=all&?sort=top&t=alltime", sub);

    // Get the response from reddit
    let response = client.get(get_str)
	.send()?;

    // Make sure the request succeeded
    if response.status() != StatusCode::OK {
	println!("Did not recieve Status 200 OK");
	panic!() // Needs better error handling but not necessary right now
    }

    // If you've made it this far, nothing left to do
    Ok(response)
}

fn main() ->  Result<(), Error> {
    // Environment variables execution location, subreddit
    let args: Vec<String> = env::args().collect();
    assert_eq!(args.len(), 2);

    // Get the top listings for the given subreddit
    let client = Client::new();
    let sub    = &args[1];
    let res    = get_top_for_sub(&client, &sub)?;

    let listings = res.json::<Listing>()?;
    println!("{:?}",listings);

    // If you've made it this far, nothing left to do
    Ok(())
}
