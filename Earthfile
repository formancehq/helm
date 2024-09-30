VERSION 0.8

IMPORT ./charts AS charts

validate:
    LOCALLY
    BUILD charts+helm-validate --PROJECT=auth
    BUILD charts+helm-validate --PROJECT=ledger

package:
    LOCALLY
    BUILD charts+helm-package --PROJECT=auth
    
publish:
    LOCALLY
    BUILD charts+helm-publish --PROJECT=auth

pre-commit:
    LOCALLY
    BUILD +validate
    BUILD +package
