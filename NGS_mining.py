# import pandas as pd
# from sklearn.model_selection import train_test_split, cross_val_score
# from sklearn.preprocessing import StandardScaler
# from sklearn.tree import DecisionTreeClassifier
# from sklearn.naive_bayes import GaussianNB
# from sklearn.neighbors import KNeighborsClassifier
# from sklearn.ensemble import RandomForestClassifier
# from sklearn.svm import SVC
# from sklearn.linear_model import LogisticRegression
# from sklearn.metrics import f1_score
#
# # Load your DataFrame x
# x = pd.read_csv('training_set.csv')
#
# # Separate features (input variables) and the target variable (Transgenic)
# features = x[['Total Reads', 'Total Alignments']]
# target = x['Transgenic']
#
# # Split the data into training and testing sets
# X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.05, random_state=42)
#
# # Define models
# models = {
#     'Decision Tree': DecisionTreeClassifier(),
#     'k-NN': KNeighborsClassifier(),
#     'Random Forest' : RandomForestClassifier()
# }
#
# # Perform cross-validation and evaluate models
# for model_name, model in models.items():
#     print('------------------------------------')
#     print(f'Model: {model_name}')
#
#     # Without data normalization
#     scores = cross_val_score(model, X_train, y_train, cv=12)
#     f1_scores = cross_val_score(model, X_train, y_train, cv=12, scoring='f1')
#     print('Without Data Normalization:')
#     print(f'Mean Accuracy: {scores.mean()}')
#     print(f'Standard Deviation: {scores.std()}')
#     print(f'Mean F1 Score: {f1_scores.mean()}')
#     print(f'Standard Deviation F1 Score: {f1_scores.std()}')
#
#     # With data normalization
#     scaler = StandardScaler()
#     X_train_normalized = scaler.fit_transform(X_train)
#     X_test_normalized = scaler.transform(X_test)
#     scores_normalized = cross_val_score(model, X_train_normalized, y_train, cv=12)
#     f1_scores_normalized = cross_val_score(model, X_train_normalized, y_train, cv=12, scoring='f1')
#     print('With Data Normalization:')
#     print(f'Mean Accuracy: {scores_normalized.mean()}')
#     print(f'Standard Deviation: {scores_normalized.std()}')
#     print(f'Mean F1 Score: {f1_scores_normalized.mean()}')
#     print(f'Standard Deviation F1 Score: {f1_scores_normalized.std()}')
#     print('------------------------------------')


# Section 2

# import pandas as pd
# from sklearn.model_selection import train_test_split, cross_val_score
# from sklearn.preprocessing import StandardScaler
# from sklearn.metrics import f1_score, accuracy_score
# from sklearn.tree import DecisionTreeClassifier
# from sklearn.neighbors import KNeighborsClassifier
# from itertools import product
# from sklearn.tree import export_text
# from sklearn.tree import export_graphviz
# import graphviz
#
# # Load your DataFrame x
# x = pd.read_csv('training_set.csv')
#
# # Separate features (input variables) and the target variable (Transgenic)
# features = x[['Total Reads', 'Total Alignments']]
# target = x['Transgenic']
#
# # Split the data into training and testing sets
# X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.05, random_state=42)
#
# # Define parameter ranges
# decision_tree_params = {}
#
# knn_params = {
#     'n_neighbors': range(3, 16),
#     'weights': ['uniform', 'distance'],
#     'p': [1],
#     'algorithm': ['auto'],
# }
#
# # Generate models
# models = []
#
# for params in product(*decision_tree_params.values()):
#     model = DecisionTreeClassifier(**dict(zip(decision_tree_params.keys(), params)))
#     models.append(('Decision Tree', model, params))
#
# # for params in product(*knn_params.values()):
# #     model = KNeighborsClassifier(**dict(zip(knn_params.keys(), params)))
# #     models.append(('k-NN', model, params))
#
# best_acc, best_f1 = 0, 0
# best_model=[]
#
# # Perform cross-validation and evaluate models
# for model_name, model, params in models:
#     # Without data normalization
#     scores = cross_val_score(model, X_train, y_train, cv=12)
#     mean_accuracy = scores.mean()
#
#     # With data normalization
#     scaler = StandardScaler()
#     X_train_normalized = scaler.fit_transform(X_train)
#     X_test_normalized = scaler.transform(X_test)
#     scores_normalized = cross_val_score(model, X_train_normalized, y_train, cv=12)
#     mean_accuracy_normalized = scores_normalized.mean()
#
#     # Compute F1 score and accuracy
#     model.fit(X_train, y_train)
#     y_pred = model.predict(X_test)
#     f1 = f1_score(y_test, y_pred)
#     accuracy = accuracy_score(y_test, y_pred)
#
#     # Print results if F1 score or accuracy is larger than 86%
#     if f1 > best_f1 or accuracy > best_acc:
#         best_f1, best_acc = f1, accuracy
#         print('------------------------------------')
#         print(f'Model: {model_name}')
#         print('Parameters:')
#         print(params)
#         print('Without Data Normalization:')
#         print(f'Mean Accuracy: {mean_accuracy}')
#         print('With Data Normalization:')
#         print(f'Mean Accuracy: {mean_accuracy_normalized}')
#         print(f'F1 Score: {f1}')
#         print(f'Accuracy: {accuracy}')
#         print('------------------------------------')
#         best_model.append(model)
#
#
# best_model=best_model[-3:]
# for model in best_model:
#     dot_data = export_graphviz(model, out_file=None, feature_names=list(features.columns), filled=True)
#     # Create the graph from the graphviz object
#     graph = graphviz.Source(dot_data)
#     # Save the decision tree graph as a PDF file
#     graph.render("decision_tree_graph", format='png')

#
# # Section 3
# import pandas as pd
# from sklearn.model_selection import train_test_split
# from sklearn.metrics import f1_score, accuracy_score
# from sklearn.neighbors import KNeighborsClassifier
# from sklearn.ensemble import RandomForestClassifier
# from itertools import product
#
# # Load your DataFrame x
# x = pd.read_csv('training_set.csv')
#
# # Separate features (input variables) and the target variable (Transgenic)
# features = x[['Total Reads', 'Total Alignments']]
# target = x['Transgenic']
#
# # Split the data into training and testing sets
# X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.05, random_state=42)
#
# # Define best models with specific parameters
# best_models = [
#     ('k-NN1', KNeighborsClassifier(n_neighbors=4, weights='distance', p=1, algorithm='auto', leaf_size=20)),
#     ('k-NN2', KNeighborsClassifier(n_neighbors=7, weights='distance', p=2, algorithm='auto', leaf_size=20)),
#     ('k-NN3', KNeighborsClassifier(n_neighbors=13, weights='distance', p=2, algorithm='auto', leaf_size=20))
# ]
#
# # Define parameter ranges for Random Forest
# random_forest_params = {
#     'n_estimators': [100, 200, 300],
#     'max_depth': [None, 5, 10],
#     'min_samples_split': [2, 5],
#     'max_features': ['sqrt', 'log2']
# }
#
# # Generate Random Forest models
# random_forest_models = []
#
# for params in product(*random_forest_params.values()):
#     model = RandomForestClassifier(**dict(zip(random_forest_params.keys(), params)))
#     random_forest_models.append(('Random Forest', model, params))
#
# # Combine all models
# # models = random_forest_models
# models = best_models
# # models = best_models + random_forest_models
#
# best_acc, best_f1 = 0, 0
#
# # Test the models and print the results
# for model_name, model in models:
#     model.fit(X_train, y_train)
#     y_pred = model.predict(X_test)
#     f1 = f1_score(y_test, y_pred)
#     accuracy = accuracy_score(y_test, y_pred)
#     if f1 > best_f1 or accuracy > best_acc:
#         best_f1, best_acc = f1, accuracy
#         print('------------------------------------')
#         print(f'Model: {model_name}')
#         print('Parameters:')
#         print(params)
#         print(f'F1 Score: {f1}')
#         print(f'Accuracy: {accuracy}')
#         print('------------------------------------')

# Section 4
#
# import pandas as pd
# from sklearn.model_selection import train_test_split, cross_val_score
# from sklearn.preprocessing import StandardScaler
# from sklearn.tree import DecisionTreeClassifier
# from sklearn.neighbors import KNeighborsClassifier
# from sklearn.metrics import f1_score, accuracy_score
#
# # Load your DataFrame x
# x = pd.read_csv('training_set.csv')
#
# # Separate features (input variables) and the target variable (Transgenic)
# features = x[['Total Reads', 'Total Alignments']]
# target = x['Transgenic']
#
# # Split the data into training and testing sets
# X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.05, random_state=42)
#
#
# knn_params = {
#     'n_neighbors': range(2, 12),
#     'weights': ['uniform', 'distance'],
#     'algorithm': ['auto', 'ball_tree', 'kd_tree', 'brute'],
#     # 'leaf_size': range(20, 41)
# }
#
# decision_tree_models = []
# knn_models = []
#
# # Generate decision tree models with different parameter combinations
# for max_depth in decision_tree_params['max_depth']:
#     # for min_samples_split in decision_tree_params['min_samples_split']:
#     #     for min_samples_leaf in decision_tree_params['min_samples_leaf']:
#     for max_features in decision_tree_params['max_features']:
#         for criterion in decision_tree_params['criterion']:
#             model = DecisionTreeClassifier(max_depth=max_depth
#                                            , max_features=max_features,
#                                            criterion=criterion)
#             decision_tree_models.append(model)
#
# # Generate k-NN models with different parameter combinations
# for n_neighbors in knn_params['n_neighbors']:
#     for weights in knn_params['weights']:
#         # for p in knn_params['p']:
#             for algorithm in knn_params['algorithm']:
#                 # for leaf_size in knn_params['leaf_size']:
#                 model = KNeighborsClassifier(n_neighbors=n_neighbors, weights=weights, p=p,
#                                              algorithm=algorithm)
#                 knn_models.append(model)
#
# best_acc, best_f1 = 0, 0
#
# # Perform cross-validation and evaluate models
# for model in decision_tree_models + knn_models:
#     model_name=type(model).__name__
#     print('------------------------------------')
#     print(f'Model: {model_name}')
#
#     # Without data normalization
#     f1_scores = cross_val_score(model, X_train, y_train, cv=12, scoring='f1')
#     print('Without Data Normalization:')
#     print(f'Average F1 Score: {f1_scores.mean()}')
#
#     # With data normalization
#     scaler = StandardScaler()
#     X_train_normalized = scaler.fit_transform(X_train)
#     f1_scores_normalized = cross_val_score(model, X_train_normalized, y_train, cv=12, scoring='f1')
#     print('With Data Normalization:')
#     print(f'Average F1 Score: {f1_scores_normalized.mean()}')
#
#     print('------------------------------------')
#
#
#     model.fit(X_train, y_train)
#     y_pred = model.predict(X_test)
#     f1 = f1_score(y_test, y_pred)
#     accuracy = accuracy_score(y_test, y_pred)
#     if f1 > best_f1 or accuracy > best_acc:
#         best_f1, best_acc = f1, accuracy
#         print('------------------------------------')
#         print(f'Prediction')
#         print(f'F1 Score: {f1}')
#         print(f'Accuracy: {accuracy}')
#         print('------------------------------------')


#
# best_model=best_model[-3:]
# for model in best_model:
#     dot_data = export_graphviz(model, out_file=None, feature_names=list(features.columns), filled=True)
#     # Create the graph from the graphviz object
#     graph = graphviz.Source(dot_data)
#     # Save the decision tree graph as a PDF file
#     graph.render(f"decision_tree_graph{model}", format='png')
#
# test_sizes = np.arange(0.2, 0.05, -0.05)
#
# # Define an empty list to store accuracy values
# accuracy_scores = []
#
# for test_size in test_sizes:
#     # Split the data into training and testing sets
#     X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=test_size, random_state=32)
#
#     # Train the model
#     model = DecisionTreeClassifier()
#     model.fit(X_train, y_train)
#
#     # Make predictions on the test set
#     y_pred = model.predict(X_test)
#
#     # Calculate and store the accuracy score
#     accuracy = accuracy_score(y_test, y_pred)
#     accuracy_scores.append(accuracy)
#
# # Plot the relationship between test_size and accuracy
# plt.plot(test_sizes, accuracy_scores, marker='o')
# plt.xlabel('Test Size')
# plt.ylabel('Accuracy')
# plt.title('Relationship between Test Size and Accuracy')


import pandas as pd
import pydotplus
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.tree import DecisionTreeClassifier, export_graphviz
from sklearn.metrics import f1_score, accuracy_score
from sklearn.preprocessing import StandardScaler, MinMaxScaler

# Load your DataFrame x
x = pd.read_csv('training_set.csv')

# Separate features (input variables) and the target variable (Transgenic)
target = x['Transgenic']
# features = x[['Coverage', "% Mapped"]]
features = x[['Coverage', 'Regional Mapped Reads', '% Adapter R1', '% Adapter R2', '% Trimmed bp R1', '% Trimmed bp R2',
              'Reads Religned Once', 'Reads Multimapped', 'Unmapped Reads', '% Reads MapQ10',"% Mapped"]]

# Perform one-hot encoding for nominal features
features_encoded = pd.get_dummies(features)

# Apply normalization to the features


# values = features_encoded["% Mapped"].values.reshape(-1, 1)


# scaler = MinMaxScaler()
#
#
# normalized_values = scaler.fit_transform(values)
#
#
# features_encoded[ "% Mapped"] = normalized_values


# Initialize the MinMaxScaler
scaler = MinMaxScaler()

# Scale the numerical columns in the DataFrame
df_scaled = pd.DataFrame(scaler.fit_transform(features_encoded.select_dtypes(include='number')), columns=features_encoded.select_dtypes(include='number').columns)

# Concatenate the scaled numerical columns with the non-numerical columns
df_scaled = pd.concat([features_encoded.select_dtypes(exclude='number'), df_scaled], axis=1)



# Define the range of max_depth and criterion
max_depths = [2, 3, 4, 5, 6]
criterion = 'entropy'

# Lists to store the best models and their performances
best_model = None
best_acc = 0.0
best_f1 = 0.0

# Loop over different max_depths
for max_depth in max_depths:
    # Create the decision tree model with specific max_depth and criterion
    model = DecisionTreeClassifier(criterion='entropy')

    # Perform cross-validation and evaluate models
    scores = cross_val_score(model, df_scaled, target, cv=12)
    mean_accuracy = scores.mean()

    scores = cross_val_score(model, df_scaled, target, cv=12, scoring='f1_macro')
    mean_f1 = scores.mean()

    # Compute F1 score and accuracy
    model.fit(df_scaled, target)
    y_pred = model.predict(df_scaled)
    f1 = f1_score(target, y_pred)
    accuracy = accuracy_score(target, y_pred)

    # Print results
    print('------------------------------------')
    print('Training Set Performance:')
    print(f'Max Depth: {max_depth}')
    print(f'Criterion: {criterion}')
    print(f'Mean Accuracy: {mean_accuracy}')
    print(f'MeanF1 Score: {mean_f1}')
    print('------------------------------------')

    # Select the best model based on F1 score or accuracy
    if f1 > best_f1 or accuracy > best_acc:
        best_f1 = f1
        best_acc = accuracy
        best_model = model

    # Split the data into training and testing sets
    X_train, X_test, y_train, y_test = train_test_split(df_scaled, target, test_size=0.3, random_state=42)

    # Fit the best model on the training data
    best_model.fit(X_train, y_train)

    # Make predictions on the test set
    y_pred = best_model.predict(X_test)

    # Calculate F1 score and accuracy on the test set
    f1 = f1_score(y_test, y_pred)
    accuracy = accuracy_score(y_test, y_pred)

    # Print the F1 score and accuracy on the test set
    print('------------------------------------')
    print('Test Set Performance:')
    print(f'F1 Score: {f1}')
    print(f'Accuracy: {accuracy}')
    print('------------------------------------')

    # Save the decision tree graph as a PNG file
    dot_data = export_graphviz(best_model, out_file=None, feature_names=list(df_scaled.columns), filled=True)
    graph = pydotplus.graph_from_dot_data(dot_data)
    graph.write_png(f"decision_tree_graph_max_depth_{max_depth}.png")
