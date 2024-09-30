VERSION 0.8

IMPORT ./charts AS charts

validate:
    LOCALLY
    #BUILD charts+helm-validate --PROJECT=agent

package:
    LOCALLY
    #BUILD charts+helm-package --PROJECT=agent
    
publish:
    LOCALLY
    #BUILD charts+helm-publish --PROJECT=agent

pre-commit:
    LOCALLY
    BUILD +validate
    BUILD +package
