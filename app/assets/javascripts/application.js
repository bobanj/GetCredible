// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jqcloud-0.2.10
//= require jquery.tipsy
//require_tree .


$(function () {
    $.getCredible = {};
    $.getCredible.tagCloudPath = null;
    $.getCredible.tagCloud = $("#tag-cloud");
    $.getCredible.vote = function (word) {
        var word = $(word);
        var voteToggle;

        if (typeof(this.tagCloudPath) == 'string' && this.tagCloud.data('logged-in') == true) {
            voteToggle = word.hasClass('vouche') ? '/vote.json' : '/unvote.json';
            $.post(this.tagCloudPath + '/' + word.data('user-tag-id') + voteToggle, function (data) {
                if (data.status == 'ok') {
                    var numVotes = word.data('votes');
                    if(word.hasClass('vouche')){
                        word.tipsy("hide");
                        word.data('votes', numVotes + 1);
                        word.removeClass("vouche").addClass("unvouche");
                        word.tipsy("show");
                    } else {
                        word.tipsy("hide");
                        word.data('votes', numVotes - 1);
                        word.removeClass("unvouche").addClass("vouche");
                        word.tipsy("show");
                    }

                }
            })
        }
    };
    $.getCredible.renderTagCloud = function () {
        if (this.tagCloud.length > 0) {
            this.tagCloudPath = this.tagCloud.data('tag-cloud-path');
            $.getJSON(this.tagCloud.data('tag-cloud-path'), function (data) {
                var word_list = [];
                $.each(data, function (i, userTag) {
                    word_list.push({
                        text:userTag.name,
                        customClass:userTag.voted ? "unvouche word" : "vouche word",
                        weight:userTag.votes,
                        title:userTag.name,
                        dataAttributes:{votes:userTag.votes, 'user-tag-id':userTag.id},
                        handlers:{click:function () {
                            $.getCredible.vote(this);
                        }}
                    });
                });
                $.getCredible.tagCloud.jQCloud(word_list, {
                    nofollow:true,
                    delayedMode:true,
                    callback:function () {
                        console.log("words are rendered, handle tipsies");
                        $("#tag-cloud .word").each(function () {
                            var word = $(this);
                            var baloonSizeClass = word.attr('class').split(' ')[0];
                            switch (baloonSizeClass) {
                                case 'w10':
                                case 'w9':
                                    baloonSizeClass = 'w5';
                                    break;
                                case 'w8':
                                case 'w7':
                                    baloonSizeClass = 'w4';
                                    break;
                                case 'w6':
                                case 'w5':
                                    baloonSizeClass = 'w3';
                                    break;
                                case 'w4':
                                case 'w3':
                                    baloonSizeClass = 'w2';
                                    break;
                                case 'w2':
                                case 'w1':
                                    baloonSizeClass = 'w1';
                                    break;
                                default:
                                    baloonSizeClass = 'w1';
                            }

                            $(this).tipsy({
                                gravity:'e',
                                fade:true,
                                html:true,
                                delayOut:50,
                                title:function () {
                                    return '<span id="" class="' + baloonSizeClass + '">' + word.data('votes') + '</span>';
                                }
                            })
                        });
                    }})
            });
        }
    }
    $.getCredible.renderTagCloud();
});