🌾 Clustering Seeds: Unsupervised Learning in R seeds_script.R is a data science project developed as part of graduate coursework. The analysis applies unsupervised machine learning techniques to explore patterns in seed characteristics and group them into meaningful clusters.

❓ Project Question Can we uncover natural groupings in seed types based on their physical characteristics—without using labels?
This analysis clusters seeds into groups using both K-means and hierarchical clustering, based on measurable features like area, perimeter, and kernel dimensions.

📊 Analysis Summary Each observation (a seed) was evaluated using the following features:
✅ Physical Characteristics
	•	Area
	•	Perimeter
	•	Compactness
	•	Length of kernel
	•	Width of kernel
	•	Asymmetry coefficient
	•	Length of kernel groove
The dataset was standardized and then clustered using:
	•	K-means clustering (for k = 3 and 4)
	•	Hierarchical clustering with average and complete linkage

📁 Contents
	•	seeds_script.R – Full R script for data processing, clustering, and plotting
	•	seeds_rmd.Rmd – R Markdown version of the analysis
	•	seeds_report.pdf – Final rendered report (PDF)
	•	seeds_dataset.txt - original dataset from UC Irvine Machine Learning Repository


⚙️ Methods and Models
📏 Preprocessing
	•	Raw data is standardized using scale()
	•	Final column (original labels) is dropped to allow for true unsupervised learning
🔢 K-Means Clustering
	•	k = 4 to explore structure
	•	k = 3 based on optimal value from the Elbow Method (fviz_nbclust)
🌳 Hierarchical Clustering
	•	Distance metric: Euclidean
	•	Linkage methods:
	◦	Average
	◦	Complete
	•	Clusters visualized using dendrograms (fviz_dend)
📈 Visualization
	•	Cluster results are plotted using PCA-based projections (fviz_cluster)
	•	Dendrograms show nested structure among data points

🔍 Key Insight Clustering reveals that wheat seed characteristics can be grouped into distinct patterns even without known labels. The project demonstrates how unsupervised learning can be used to discover hidden structure in agricultural or biological data.

Created by: Molly Szeman Last Updated: June 2025