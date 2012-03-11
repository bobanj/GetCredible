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
    $.getCredible.createWordList = function (data) {
        var wordList = [];
        $.each(data, function (i, userTag) {
            wordList.push({
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
        return wordList;
    }
    $.getCredible.renderTagCloud = function (wordList) {
        $.getCredible.tagCloud.html('');
        $.getCredible.tagCloud.jQCloud(wordList, {
            nofollow:true,
            delayedMode:true,
            callback:function () {
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
    }

    $.getCredible.updateTagCloud = function () {
        if (this.tagCloud.length > 0) {
            this.tagCloudPath = this.tagCloud.data('tag-cloud-path');
            $.getJSON(this.tagCloud.data('tag-cloud-path'), function (data) {
                $.getCredible.renderTagCloud($.getCredible.createWordList(data));
            });
        }
    }

    $("#add-tag form").submit(function(e){
        e.preventDefault();
        var input = $('#tag_names');
        var tagNames  = input.val();
        if (tagNames.length && $.getCredible.tagCloud.length > 0) {
            input.val('');
            $.getCredible.tagCloud.html("loading...");
            $.post($.getCredible.tagCloud.data('tag-cloud-path'), {tag_names: tagNames}, function (data) {
                $.getCredible.renderTagCloud($.getCredible.createWordList(data));
            });
        }
        return false;
    });

    $.getCredible.updateTagCloud();
});