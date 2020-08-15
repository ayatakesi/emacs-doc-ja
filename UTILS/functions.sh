#!/usr/bin/env bash

#
# emacs本家のdoc/取得用
#
function run_once_for_checkout_UPSTREAM () {
    REPO=${1};
    cd ${REPO};
    git clone \
	--filter=blob:none \
	--no-checkout \
	https://github.com/emacs-mirror/emacs.git;
    
    git -C emacs sparse-checkout init --cone;
    git -C emacs sparse-checkout set /doc;
    cd -;
}

function checkout_by_ver_UPSTREAM () {
    REPO=${1};
    VER=${2};
    git -C ${REPO} pull;
    git -C ${REPO} checkout "refs/tags/emacs-${VER}";
}

#
# 【移行用】未翻訳とタイトル翻訳済のtexiからタイトル翻訳用po生成
#
function generate_titlezpo_by_translated_texi () {
    
    ORIGINAL_TEXI_DIR=$(realpath ${1}); # /.../original_texis
    JAPANESE_TEXI_DIR=$(realpath ${2}); # /.../japanese_texis
    TITLES_ROOT_DIR=$(realpath ${3}); # /.../TITLES
    JAPANESE_TEXI_SUFFIX=${4}; # "", "-ja", ...

    # create out dir
    TITLES_PO_DIR=${TITLES_ROOT_DIR}/ja/LC_MESSAGES;
    if [ -d ${TITLES_PO_DIR} ]
    then
	mkdir -p ${TITLES_PO_DIR}
    fi
    
    for TEXI0 in ${ORIGINAL_TEXI_DIR}/*.texi
    do
	RM_FILES=; # for rm -f ${RM_FILES}
	TEXI=$(basename ${TEXI0}); # xxx.texi
	TEXI_NAME=$(basename ${TEXI} .texi) # xxx
	JAPANESE_TEXI=${TEXI_NAME}${JAPANESE_TEXI_SUFFIX}.texi
	JAPANESE_TEXI0=${JAPANESE_TEXI_DIR}/${JAPANESE_TEXI}
	# xtract not-translated-titles
	EN_TITLE=$(mktemp); RM_FILES+="${EN_TITLE} "
	grep -E '^@((chapter)|((sub)*(section))|(appendix)(sub)*(sec)?)' ${TEXI0} > ${EN_TITLE}
	
	# xtract translated-titles
	JA_TITLE=$(mktemp); RM_FILES=+="${JA_TITLE} "
	grep -E '^@((chapter)|((sub)*(section))|(appendix)(sub)*(sec)?)' ${JAPANESE_TEXI0} > ${JA_TITLE}

	# create po-seed
	cat <<'EOT' > ${TITLES_PO_DIR}/${TEXI}.po
msgid ""
msgstr ""
"Project-Id-Version: Emacs-XX.X\n"
"POT-Creation-Date: 2020-08-15 00:00+0900\n"
"PO-Revision-Date: 2020-08-15 00:00+0900\n"
"Last-Translator: emacs-jp#translations\n"
"Language-Team: emacs-jp#translations\n"
"Language: ja\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"

EOT
	# join and filter to po-format
	paste ${EN_TITLE} ${JA_TITLE} |
	    perl -ne '
chomp;
($en, $ja) = split "\t";
$ja = \"\" if $en ne $ja;
print "msgid \"${en}\"\nmsgstr \"${ja}\"\n\n";' >> ${TITLES_PO_DIR}/${TEXI}.po
	
	rm -f ${RM_FILES}
    done
}

#
# Makefileで使用
#
function translate_texi_except_titles () {
    
    TEXI0=$(realpath ${1}); # /.../xxx.texi
    JA_TEXI_DIR=$(realpath ${2}); # /.../japanese_texis
    PO_DIR=$(realpath ${3}); # /.../.
    JA_TEXI_SUFFIX=${4}; # "", "-ja", ...

    TEXI=$(basename ${TEXI0}) # xxx.texi
    TEXI_NAME=$(basename ${TEXI} .texi) # xxx
    JA_TEXI=${TEXI_NAME}${JA_TEXI_SUFFIX}.texi

    echo -n "Processing ${FUNCNAME[0]}: ${TEXI} ... "
    if [ -f ${PO_DIR}/${TEXI}.po ]
    then
	po4a-translate -f texinfo \
		       -k 0 \
		       -M utf8 \
		       -m ${TEXI0} \
		       -p ${PO_DIR}/${TEXI}.po \
		       -l ${JA_TEXI_DIR}/${JA_TEXI};
    else
	cp -p ${TEXI0} ${JA_TEXI_DIR}/${JA_TEXI}
    fi

    echo "done."
}

function translate_title_by_gettext () {
    EN_TEXI0=$(realpath ${1}); # /.../original_texis/xxx.texi
    JA_TEXI_DIR=$(realpath ${2}); # /.../japanese_texis
    TITLES_ROOT_DIR=$(realpath ${3}); # /.../TITLES
    JA_TEXI_SUFFIX=${4}; # "", "-ja", ...
    
    EN_TEXI=$(basename ${EN_TEXI0}) # xxx.texi
    JA_TEXI="$(basename ${EN_TEXI} .texi)${JA_TEXI_SUFFIX}.texi"
    RM_FILES=; # for rm -f ${RM_FILES}

    echo -n "Processing ${FUNCNAME[0]}: ${EN_TEXI} ... "
    # compile po to mo
    CTLG_DIR=${TITLES_ROOT_DIR}/ja/LC_MESSAGES;
    msgfmt -o ${CTLG_DIR}//${EN_TEXI}.mo \
	   ${CTLG_DIR}//${EN_TEXI}.po
    RM_FILES+=" ${CTLG_DIR}//${EN_TEXI}.mo"
    
    # generate tmp i18n filter use above mo
    PERL=$(mktemp);
    cat <<EOT >${PERL}
#!/usr/bin/perl
# This script requires libintl-perl(>=1.09).
use Locale::TextDomain ("${EN_TEXI}" => "${TITLES_ROOT_DIR}");
my (\$en, \$ja);
while (<>) {
EOT
    grep -E '^@((chapter)|((sub)*(section))|(appendix)(sub)*(sec)?)' ${EN_TEXI0} |
	sed -r "s/'/\\\'/g" |
	sed -r "s|(.+)$|\t\(\$en, \$ja\) = \(quotemeta\('&'\), __ '&'\); s/\$en/\$ja/;|" >>${PERL};
    printf "\tprint;\n}" >>${PERL}
    RM_FILES+=" ${PERL}"

    cat ${JA_TEXI_DIR}/${EN_TEXI} |
	LANGUAGE=ja perl ${PERL} > ${JA_TEXI_DIR}/${JA_TEXI}

    echo "done."
    
    rm -f ${RM_FILES}
}

function sed_for_L11N_namer_at_include () {
    EN_TEXI_DIR=$(realpath ${1}); # /.../original_texis
    JA_TEXI_DIR=$(realpath ${2}); # /.../japanese_texis
    JA_TEXI_SUFFIX=${3}; # "", "-ja", ...
    
    test "${JA_TEXI_SUFFIX}"x == x && exit;
    
    echo -n "Processing ${FUNCNAME[0]}: ${JA_TEXI_DIR}/*${JA_TEXI_SUFFIX}.texi ... "
    for EN_TEXI0 in ${EN_TEXI_DIR}/*.texi
    do
	EN_TEXI=$(basename ${EN_TEXI0}); # xxx.texi
	JA_TEXI=$(basename ${EN_TEXI} .texi)${JA_TEXI_SUFFIX}.texi # xxx-ja.texi
	sed -i -r "s/${EN_TEXI}/${JA_TEXI}/g" ${JA_TEXI_DIR}/*${JA_TEXI_SUFFIX}.texi
    done
    echo "done."
}








$*
