#docker run --rm -it -v $PWD:/input multifractal/ggplots:v4.1.1
library(purrr)
library(readr)
install.packages("readr")


list_of_files <- list.files( pattern = "*.tsv",
                            full.names = TRUE)
df <- list_of_files %>%
  set_names() %>% 
  map_dfr(
    ~ read_tsv(.x, col_types = cols(), col_names = FALSE),
    .id = "Prediction_tool"
  )


## get toolnames   gsub("\\..*", "", x)
df$Prediction_tool<-gsub("\\./*","",as.character(df$Prediction_tool))
df$Prediction_tool<-gsub("_.*", "",as.character(df$Prediction_tool))
df

uniformtheme <- theme_classic() +
		 	theme(legend.position="top", legend.direction="horizontal", legend.title = element_blank()) +
			# theme(legend.position = "none") +
		 	theme(legend.title = element_blank()) +
  		 	theme(axis.title.x=element_blank(),
        		 axis.text.x=element_text(size=30)
        		# axis.ticks.x=element_blank()
				)

plot <- ggplot(data = df, aes(x=Prediction_tool, y=X1, fill=X2)) + 
    geom_tile()
    ylab("Contigs") +
    labs(title = "Predictions") +
	uniformtheme +
    theme(plot.title = element_text(size=30))+
    theme(text = element_text(size=30), axis.text.x = element_text(angle = 90, hjust = 1))
print(plot)

    ggsave(paste0("heatmap_test.jpeg"), plot, width = 25, height = 10, dpi = 300, device="jpeg")

  