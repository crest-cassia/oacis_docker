#!/bin/bash
set -eux
git clone https://github.com/yohm/nagel_schreckenberg_model.git
cd nagel_schreckenberg_model
bundle install --path=vendor/bundle
$OACIS_ROOT/bin/oacis_ruby register_on_oacis.rb

