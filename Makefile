fmt:
	terraform fmt -recursive

fmt-check:
	terraform fmt -recursive -check

setup-git-hooks:
	rm -rf .git/hooks
	(cd .git && ln -s ../.git-hooks hooks)

cleanup-after-training:
	# Delete RKE2 Examples
	make _tf_destroy DIR=rke2-auto
	make _tf_destroy DIR=rke2-manual

	make _tf_destroy DIR=cluster-debian
	make _tf_destroy DIR=cluster-rke-template
	make _tf_destroy DIR=do-nodes
	make _tf_destroy DIR=do-nodes-rke2

	# Delete Kubernetes First
	make _tf_destroy DIR=cluster-imported
	make _tf_destroy DIR=do-kubernetes

	# Delete Rancher Global config
	make _tf_destroy DIR=global

	# Delete Rancher Bootstrap config
	make _tf_destroy DIR=bootstrap

	# Delete Rancher Instance
	make _tf_destroy DIR=rancher

	# Delete core config (SSH keys, ...)
	make _tf_destroy DIR=core

	make _chceck_cleanup

_tf_destroy:
	cd terraform/$(DIR) && terraform destroy -auto-approve

_chceck_cleanup:
	for d in terraform/*; do if [ -d "$$d" ]; then ( echo $$d && cd "$$d" && terraform state list ) fi done
