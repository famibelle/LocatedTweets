#inspiration came from http://davetang.org/muse/2013/04/06/using-the-r_twitter-package/
#install.packages("ROAuth")
#install.packages("twitteR")
#install.packages("wordcloud")
#install.packages("tm")
#install.packages("devtools")
#library(devtools)
# install.packages("SnowballC")
#install_github("timjurka/sentiment")
#install_url("http://cran.r-project.org/src/contrib/Archive/sentiment/sentiment_0.2.tar.gz")

# require(sentiment)
require(graphics)

library(twitteR)
library(shiny)
library(ROAuth)
library(RColorBrewer)
library(tm)
library(wordcloud)
library(googleVis)
library(ggplot2)
library(gridExtra)
library(plyr)
library(igraph)
library(stringr)
library(SnowballC)
library(ape) # for the phylogenetic dendrogram
library(ggdendro)

# load all the needed twitter authentication 
load("twitter.authentication")
registerTwitterOAuth(twitCred)

geocode = "47.5270932,1.8896484,600km" # around France

# Shiny main program
shinyServer(
    function(input, output, session) {
        r_stats <- reactive({
            QueryResult <- searchTwitteR(input$TwitterQuery,
                                            n = input$n_Tweets, 
#                                             since = as.character(input$daterange[1]),
#                                             until = as.character(input$daterange[2]),
#                                             lang = input$lang,
                                            geocode = geocode,
                                            cainfo = "cacert.pem")                
            
            #Transform the list into a neat dataframe
            do.call("rbind", lapply(QueryResult, as.data.frame))            
        })
        
        output$TwitterQuery <- renderDataTable({
                    r_stats()[,c("screenName", "text", "created") ]
        })
    
        output$sentiment <- renderGvis({
            withProgress(message = 'Calculation in progress',
                         detail = 'This may take a while...', value = 0, {
                             QueryFibre <- r_stats()
                         }
            )
            QueryFibre.Copy <- QueryFibre
            QueryFibre$LatLon <- paste(QueryFibre$latitude, QueryFibre$longitude, sep = ":")
            QueryFibre$alban <- paste(QueryFibre$screenName, substring(QueryFibre$text, first = 1, last = 40), sep = "<BR>")
            QueryFibre$status <- paste(
                "<b>",
                "@",
                '<a href="', 
                "https://twitter.com/marinecrlr/status/", 
                QueryFibre$id, '">', 
                QueryFibre$screenName, 
                "</b>",
                "</a>",
                "<p>",
#                 remove all the escape characters
                str_replace_all(QueryFibre$text, "[^[:alnum:]]", " "),
                sep=""
                )
            
            FibreMap <- gvisMap(QueryFibre, 
                                locationvar = "LatLon",
                                tipvar = "status", 
                                options=list(showTip=TRUE, 
                                             showLine=TRUE, 
                                             width="640px", height="480px",
                                             enableScrollWheel=TRUE,
                                             mapType='terrain', 
                                             useMapTypeControl=TRUE,
                                             icons=paste0("{",
                                                          "'default': {'normal': 'https://g.twimg.com/",
                                                          "dev/documentation/image/",
                                                          "Twitter_logo_blue_32.png',\n",
                                                          "'selected': 'https://g.twimg.com/",
                                                          "dev/documentation/image/",
                                                          "Twitter_logo_blue_16.png'",
                                                          "}}"))
                                )
            
            
            return(FibreMap)
        })

    }
)