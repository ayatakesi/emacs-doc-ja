#!/usr/bin/env bash

#
# emacs本家のdoc/取得用
#
function run_once_for_checkout_UPSTREAM () {
    REPO=${1};
    cd ${REPO};
    git clone \
	--no-checkout \
	https://git.savannah.gnu.org/git/emacs.git;
    
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
# 新版への移行
# original_texis/*.texiを新版に更新後(手コピー)に実行
#

# タイトル以外の本文
function msgmerge_newtexi_and_oldpo () {
    ORIGINAL_TEXIS_DIR=${1}; # ?/.../original_texis 
    PO_DIR=$(realpath ${2}); # /.../.
    for TEXI0 in ${ORIGINAL_TEXIS_DIR}/*.texi
    do
	TEXI=$(basename ${TEXI0});
	PO=${PO_DIR}/${TEXI}.po;
	if [ -f ${PO} ]
	then
	    POT=${PO}t;
	    MERGED_TMP=$(mktemp);
	    po4a-gettextize -M utf8 \
			    -f texinfo \
			    -m ${TEXI0} \
			    -p ${POT};
	    
	    msgmerge --previous \
		     --compendium ${PO} \
		     -o - /dev/null ${POT} |
		msgcat --no-wrap - > ${MERGED_TMP};
	    
	    cp -p ${MERGED_TMP} ${PO};
	    rm -f ${MERGED_TMP} ${POT};
	fi
    done
}

# タイトル
function msgmerge_newtexi_and_oldtitle() {
    ORIGINAL_TEXIS_DIR=$(realpath ${1}); # /.../original_texis
    TITLES_PO_DIR=$(realpath ${2}); # /.../TITLES/ja/LC_MESSAGES
    for TEXI0 in ${ORIGINAL_TEXIS_DIR}/*.texi
    do
	TEXI=$(basename ${TEXI0});
	PO=${TITLES_PO_DIR}/${TEXI}.po;
	POT=${PO}t;
	GREP_OUT=$(mktemp);
	GREP_STRING='^@((chapter)|((sub)*(section))|(appendix)(sub)*(sec)?)';
	grep -E ${GREP_STRING} ${TEXI0} >${GREP_OUT};
	if [ $? -eq 0 ]
	then
	    DATE_STRING=$(date --iso-8601=minutes | sed 's/T/ /');
	    cat <<EOT > ${POT}
msgid ""
msgstr ""
"Project-Id-Version: Emacs-XX.X\n"
"POT-Creation-Date: ${DATE_STRING}\n"
"PO-Revision-Date: ${DATE_STRING}\n"
"Last-Translator: emacs-jp#translations\n"
"Language-Team: emacs-jp#translations\n"
"Language: ja\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"

EOT
	    perl -ne 'chomp; print "msgid \"$_\"\nmsgstr \"\"\n\n";' ${GREP_OUT} >>${POT};

	    MERGED_TMP=$(mktemp);
	    msgmerge --previous \
		     --compendium ${PO} \
		     -o - /dev/null ${POT} |
		msgcat --no-wrap - > ${MERGED_TMP};

	    cp -p ${MERGED_TMP} ${PO};
	    rm -f ${MERGED_TMP} ${POT}
	    
	fi

	rm -f ${GREP_OUT};
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
    msgfmt -o ${CTLG_DIR}/${EN_TEXI}.mo \
	   ${CTLG_DIR}/${EN_TEXI}.po
    RM_FILES+=" ${CTLG_DIR}/${EN_TEXI}.mo"
    
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
	sed -r "s|(.+)$|\t\(\$en, \$ja\) = \(quotemeta\('&'\), __ '&'\); s/^\$en\$/\$ja/;|" >>${PERL};
    printf "\tprint;\n}" >>${PERL};
    RM_FILES+=" ${PERL}";

    OUTTMP=$(mktemp);
    cat ${JA_TEXI_DIR}/${JA_TEXI} |
	LANGUAGE=ja perl ${PERL} > ${OUTTMP};
    cp -pf ${OUTTMP} ${JA_TEXI_DIR}/${JA_TEXI};
    RM_FILES+=" ${OUTTMP}";
    
    echo "done."
    
    rm -f ${RM_FILES}
}

function sed_for_L11N_name_at_include () {
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

# custom merge driver("gettext-msgmerge")
# msgmerge,s --update doesn't work as I expect. 
function gettext-msgmerge-function () {
# This is the information we pass through in the driver config via
# the placeholders `%A %O %B %P`
# %A = tmp filepath to our version of the conflicted file
# %O = tmp filepath to the base version of the file
# %B = tmp filepath to the other branches version of the file
# %P = placeholder / real file name
# %L = conflict marker size (to be able to still serve according to this setting)

    OURS=${1};
    BASE=${2}; # not use
    THEIRS=${3};
    FILENAME=${4}; # not use

    TMPFILE=$(mktemp);
    msgmerge --verbose \
	     --previous \
	     --no-wrap \
	     --compendium ${THEIRS} \
	     /dev/null ${OURS} >${TMPFILE};

    mv --update ${TMPFILE} ${OURS};
}

$*
