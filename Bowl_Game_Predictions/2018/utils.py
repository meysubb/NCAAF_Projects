import numpy as np

def report(results, n_top=3):
    for i in range(1, n_top + 1):
        candidates = np.flatnonzero(results['rank_test_score'] == i)
        for candidate in candidates:
            print("Model with rank: {0}".format(i))
            print("Mean validation score: {0:.3f} (std: {1:.3f})".format(
                  results['mean_test_score'][candidate],
                  results['std_test_score'][candidate]))
            print("Parameters: {0}".format(results['params'][candidate]))
            print("")
            
            
def setup_data(df,s,target_col,names=False):
    y = df[target_col]
    X = df.drop(target_col,axis=1)
    if(names):
        c_names = X
        X = s.fit_transform(X)
        return(X,y,c_names)
    else:
        X = s.fit_transform(X)
        return(X,y)