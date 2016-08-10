# restaurant_finder
A restaurant recommendation engine based on a custom ranking algorithm

**Inputs:** City/Country and n(number of restaurants)

**Output:** Top n restaurants in the city/country


Why Not Yelp or TripAdvisor?
----------------------------

1. The most popular restaurant finding platforms like Yelp and TripAdvisor heavily favour large restaurants that have many visitors and reviews, although small restaurants may be just as positively reviewed. On these platforms, you often have to go to page 5+ of a big city to find a restaurant with less than 100 reviews, but these small restaurants turn out to be just as good if not better than large ones.

2. From personal experience, I find that reviewers on these sites are too lenient. They give five-star reviews even when the food is mediocre at best.

~~Yelp~~

~~TripAdvisor~~

*It's time for a better ranking algorithm!*

Implementation
--------------

1. Scrape restaurant reviews.
 * TripAdvisor API only returned the top 10 restaurants in a city. That wasn't enough information to work with.
 * Yelp is supported in less than 30 countries...
2. Create a ranking algorithm that addresses the two problems listed above.

About the Ranking Algorithm
---------------------------

**Inputs:** Total # of Ratings, % of Positive Ratings, Standard Deviation of Reviews

**Output:** Restaurant Score

* The total ratings is used as input to an asymptotic function, making the total number of ratings in the restaurant only relevant to a certain number of reviews (~50), preventing discrimination against small restaurants, while still eliminating restaurants that no one visits.
* The percentage of positive ratings gives an indicator as to how well-received the restaurant is on average.
* High standard deviation of reviews for a restaurant indicates that there are very mixed reviews and suggests that food quality is not consistent.
* Negative reviews were weighted much heavier than positive reviews in order to approach issue 2. In Yelp, a five star review can completely cancel with a one star review, but in my algorithm 1 and 2 star reviews are double weighted.


In my code, I also included a more efficient ranking algorithm called the Wilson's 95% Confidence Interval. It's uses a binomial proportion confidence interval to rank restaurants and it is implemented in the ci_lower_bound method.
