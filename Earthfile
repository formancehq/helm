VERSION 0.8

IMPORT ./charts AS charts

validate:
    LOCALLY
    BUILD charts+helm-validate --PROJECT=demo
    
package:
    LOCALLY
    BUILD charts+helm-package --PROJECT=demo
    
publish:
    LOCALLY
    BUILD charts+helm-publish --PROJECT=demo
    
pre-commit:
    LOCALLY
    BUILD +validate
    BUILD +package
