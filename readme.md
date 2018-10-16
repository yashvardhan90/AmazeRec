
AmazeRec : You'll want to buy these!


Introduction and Motivation
The recommendations which use metrics like rmse are based on explicit ratings which are not always reliable in figuring out what the user really wants. We want to make use of product reviews, in particular the sentiments in the reviews left by the users. The choice of words by a user is indicative of her preference/dislike towards a certain type of product. By combining this insight with traditional algorithms like collaborative filtering/Matrix Factorization, we create a recommender system that is more personalized to the user.

Another improvement our recommender provides is the inclusion of standard reviews of recommended item from reputed sources rather than from other users. Collaborative filtering does a good job at identifying the user interest but the actual reviews from other users provide little information about the item. Instead, reading a review of recommended book in our case by New York times will provide a lot more relevant information to the user.
Related Work
There are various approaches for recommenders that incorporate the reviews information to provide better recommendation e.g. HFT (Hidden Factors and Hidden Topics) which combine latent rating dimensions (such as those of latent-factor recommender systems) with latent review topics (such as those learned by topic models like LDA) . We were inspired by this idea and wanted to incorporate the simple sentiment information of the reviews in light weight.collaborative filtering models that does not add much of learning time and verify their performance on this new added feature.

Proposed solution
Our approach was to the get the sentiment score of the review on a scale of -1 to 1(-1= very bad, 1=very good) and then augment the actual rating with the sentiment score. We tried various approaches to mix them

Scaling the sentiment score from 1-5 and averaging it with actual rating
Adding the sentiment score directly to the rating
Suppressing the less signinficant reviews i.e. sentiment score between -0.5 to 0.5, and considering only the impact of only the stronger reviews.
Just using the sentiment scores to get the recommendations
We found the best results for third approach opf supressing the less significant reviews. Our Recommendation system invlolves following steps:
Get sentiment scores
Add the sentiment scores(suppresses) with rating to generate new ratings on a scale of 5.5 to 0.5
Get the recommendation based on chosen algorithm
Extract the actual standand reviews of the books obtained via NYT API
We tried this approach across various recommendation algorithms viz. simple Collaborative Filtering, Collaborative filtering with biases, Latent factors model, implicit factorization model. Although implicit feedback model does not consider ratings we used this to compare the MRR(Mean Reciprocal rating) with explicit factorization model. 

Recommender Demo : For demo we have our recommender running in backend which writes the recommendations for a user in .json file. It is then loaded from the server when the user logs in. Then, website dynamically loads the book details and also its reviews though the Google API to provide the user with our recommendations for her.
Evaluation and analysis of results
We have used RMSE and MAE as a metric to compare the performance of the recommender. Additionally we have extracted the top-k recommendations for a few users and compared the ranks of recommended items. As we found it would be inefficient to find the recommendation for all the items for a user we considered only the items which close by users have rated. Also, we compared the MRR scores to evaluate the performance of various approaches.

Collaborative Filtering: MAE: 0.67 , RMSE: 0.99
Collaborative filtering with sentiment scores: MAE: 0.842, RMSE: 1.19
SVD without sentiment scores: RMSE: 0.7432 MAE: 0.5305
SVD with sentiment scores: RMSE: 0.7873 MAE: 0.4928
MRR for Implicit and ecplicit factorization: 0.01 & 0.02
MRR for Implicit and ecplicit factorization(with sentiment): 0.01 & 0.02 (MRR score did not change)


Even Though RMSE Increased after adding sentiment scores, we observed that the for users with many neighbors ranks for top 50 items did not change much but he corresponding rating scale of prediction now varied from (0.5 to 5.5) providing more distinctions in top recommendations based on user review. For users users with few neighbours it will be a good idea as we he will get the recommendation of neighbor with strong review than of equidistant neighbor with lighter reviews. Also, we felt that mse might not always be the best way to compare a system that uses sentiment scores with one that uses ratings. So we used NDCG to calculate the effectiveness and found that the systems were almost equivalent in performance (0.923 vs 0.936)
Discussion
Providing the user with our recommendations in an effective manner proved to be challenging. There were several issues to consider :

The biggest challenge was to decide the approach on using the review information to power the recommender. Even for calculating the sentiment score, a naive approach that assigns a score for each word and then aggregating the scores wouldn’t have worked well. We had to find a parser that calculated sentiment scores more intelligently. We used 'valence aware sentimet dictionary and sentiment reasoner (VADER)'
Since we tried many approaches many of which yielded comparable results, we couldn’t decide how to better the accuracies even further. Our models include collaborative, SVD and BPR with ratings and/or sentiment scores.
We found that user review could not be discarded and managed to get good results from the reviews. However a more complex model akin to HFT would probably give better results.
How to provide useful information to the user regarding the product?
We use the Google API to obtain reviews from reputed sources like nytimes.com, npr.org, washingtonpost.com etc.
We would like to deploy our system and try to get feedback from actual users, we believe that this is the best way to evaluate our system. Right now, our system relies on the user's caching to get the item details which is not realistic. In a practical system, we would need to have a database of all the item details from which the details can be queried dynamically.


Project Demo : https://vorzawk.github.io/irProjectWebsite/ 
