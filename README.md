# Online Emotions During the Storming of the U.S. Capitol: Evidence from the Social Media Network Parler

In this repository, we provide both code and data for our study on online emotions on the social network Parler during the storming of the U.S. Capitol. Implementation is based on R (version 4.1.1). 

The main implementation is a .Rmd file that utilizes some additional functionalities (e.g., to upload and download large data files via GitHub) provided [here](https://github.com/jhnnsjkbk/EmotionDynamics/blob/main/code/large_data_files.R) as well as [some utils](https://github.com/jhnnsjkbk/EmotionDynamics/blob/main/code/utils.R).

:rocket: Our paper got accepted at [ICWSM'23](https://www.icwsm.org/2023/index.html/).

:books: Our paper is available on [arXiv](https://arxiv.org/pdf/2204.04245.pdf).

## Abstract
The storming of the U.S. Capitol on January 6, 2021 has led to the killing of 5 people and is widely regarded as an attack on democracy. The storming was largely coordinated through social media networks such as Parler. Yet little is known regarding how users interacted on Parler during the storming of the Capitol. In this work, we examine the emotion dynamics on Parler during the storming with regard to heterogeneity across time and users. For this, we segment the user base into different groups (e.g., Trump supporters and QAnon supporters). We use affective computing (Kratzwald et al. 2018) to infer the emotions in the contents, thereby allowing us to provide a comprehensive assessment of online emotions. Our evaluation is based on a large-scale dataset from Parler, comprising of 717,300 posts from 144,003 users. We find that the user base responded to the storming of the Capitol with an overall negative sentiment. Akin to this, Trump supporters also expressed a negative sentiment and high levels of unbelief. In contrast to that, QAnon supporters did not express a more negative sentiment during the storming. We further provide a cross-platform analysis and compare the emotion dynamics on Parler and Twitter. Our findings point at a comparatively less negative response to the incidents on Parler compared to Twitter accompanied by higher levels of disapproval and outrage. Our contribution to research is three-fold: (1) We identify online emotions that were characteristic of the storming; (2) we assess emotion dynamics across different user groups on Parler; (3) we compare the emotion dynamics on Parler and Twitter. Thereby, our work offers important implications for actively managing online emotions to prevent similar incidents in the future.

In the following, we provide several figures that visualize our contributions. 

## Timeline of the events 

![Timeline of key events during the storming of the U.S. Capitol.](/figures/Timeline.png)


## Sentiment on Parler over time 

![Sentiment (hourly) in Parler network between De- cember 30, 2020 and January 9, 2021.](/figures/Sentiment_Parler.png)


## Sentiment on Parler compared to Twitter before, during, and after the storming of the U.S. Capitol 

![Emotion dynamics (hourly) of sentiment on Parler and Twitter on January 6, 2021.](/figures/Sentiment_Parler_Twitter.png)

## Emotion dynamics for different user groups 

![Emotion dynamics (hourly) of (a) sentiment and (b) derived emotions for different user groups.](/figures/User_groups.png)






### Please cite as follows:
Jakubik, J., Vössing, M., Bär, D., Pröllochs, N., & Feuerriegel, S. (2023). Online Emotions During the Storming of the US Capitol: Evidence from the Social Media Network Parler. 17th International AAAI conference on web and social media.
 