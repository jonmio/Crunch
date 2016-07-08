# restaurant_finder
A restaurant ranking algorithm and web-scraper

Restaurant finder takes a city or country as input and scrapes the trip advisor site for all restaurants in the area. All the restaurant reviews are also scraped, and they are processed and put through a ranking algorithm I wrote. After scraping is complete, it will prompt the user to enter the number of restaurants they would like to view, and the program will return the top n restaurants in order. 


Issues
1) The most popular restaurant finding platforms like Yelp and TripAdvisor heavily favour large restaurants that have many visitors and reviews, although small restaurants may be just as positively reviewed. On these platforms, you often have to go to page 5+ of a big city to find a restaurant with less than 100 reviews, but these small restaurants turn out to be just as good if not better than large ones.

2) From personal experience, I find that reviewers on these sites are too lenient. They give five-star reviews even when the food is mediocre (in my opinion).

With my restaurant finder, I attempted to fix these two problems by creating my own ranking algorithm. My ranking algorithm is a function with three inputs: total ratings, % of positive ratings and standard deviation of reviews. The total ratings is used as input to an asymptotic function, making the total number of ratings in the restaurant only relevant to a certain number of reviews (~50), preventing discrimination against small restaurants, while still eliminating restaurants that are extremely small.

I weighted negative reviews much heavier than positive reviews in order to approach issue 2. In Yelp, a five star review can completely cancel with a one star review, but in my algorithm 1 and 2 star reviews are double weighted.  
