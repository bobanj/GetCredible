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
//= require jquery.noty
//require_tree .


$(function () {
    $.getCredible = {};
    $.getCredible.tagCloudPath = null;
    $.getCredible.tagCloudLoader = $("#tag-cloud-loader");
    $.getCredible.tagCloud = $("#tag-cloud");
    $.getCredible.vote = function (word) {
        var word = $(word);
        var voteToggle;

        if (typeof(this.tagCloudPath) == 'string') {
            voteToggle = word.hasClass('vouche') ? '/unvote.json' : '/vote.json';
            if (this.tagCloud.data('logged-in') == false) {
                noty({text:'Please login so you can vouche', type:'alert', timeout:2500});
                return false;
            }

            if (this.tagCloud.data('can-vote')) {
                $.post(this.tagCloudPath + '/' + word.data('user-tag-id') + voteToggle, function (data) {
                    if (data.status == 'ok') {
                        var numVotes = word.data('votes');
                        var user = $.getCredible.tagCloud.data('user');
                        if (word.hasClass('vouche')) {
                            word.tipsy("hide");
                            word.data('votes', numVotes - 1);
                            word.removeClass("vouche").addClass("unvouche");
                            noty({text:'You have unvouched for ' + user.first_name + ' on ' + word.text(), type:'success', timeout:800});
                            word.tipsy("show");
                        } else {
                            word.tipsy("hide");
                            word.data('votes', numVotes + 1);
                            word.removeClass("unvouche").addClass("vouche");
                            noty({text:'You have vouched for ' + user.first_name + ' on ' + word.text(), type:'success', timeout:800});
                            word.tipsy("show");
                        }

                    }
                });
            } else {
                if (!this.tagCloud.data('can-delete')) {
                    noty({text:'You can not vouche for yourself', type:'alert', timeout:2500});
                }
            }
        } else {
            noty({text:'You are not authorized for this action', type:'error', timeout:2500});
        }
    };
    $.getCredible.createWordList = function (data) {
        var wordList = [];
        var customClass = "word ";
        customClass += this.tagCloud.data('can-delete') ? 'remove ' : '';
        if(data.length == 0){
            return wordList;
        }
        var min = data[0].votes;
        var max = data[0].votes;
        var parts = 10;
        $.each(data, function (i, userTag) {
           if(userTag.votes > max){max = userTag.votes;}
           if(userTag.votes < min){min = userTag.votes;}
        });
        var divisor = (max - min) / parts;
        $.each(data, function (i, userTag) {
            wordList.push({
                text:userTag.name,
                customClass:function () {
                    var pom = customClass + '';
                    if ($.getCredible.tagCloud.data('can-vote')) {
                        pom += userTag.voted ? "vouche " : "unvouche ";
                    }
                    return pom;
                },
                weight: parseInt((userTag.votes - min) / divisor),
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
        $.getCredible.tagCloudLoader.show('fast');
        $.getCredible.tagCloud.html('');
        $.getCredible.tagCloud.jQCloud(wordList, {
            nofollow:true,
            delayedMode:true,
            callback:function () {
                $.getCredible.tagCloudLoader.hide('fast');
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
                    }).append('<span class="icon"></span>');
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

    $("#tag-cloud").delegate(".remove .icon", "click", function () {
        var word = $(this).parent();
        noty({
            text:'Are you sure you want to delete this tag?',
            layout:'center',
            type:'alert',
            buttons:[
                {type:'button green', text:'Ok', click:function () {
                    if ($.getCredible.tagCloud.data('can-delete')) {
                        $.post($.getCredible.tagCloudPath + '/' + word.data('user-tag-id'), { _method:'delete' }, function (data) {
                            $.getCredible.renderTagCloud($.getCredible.createWordList(data));
                        });
                    }
                } },
                {type:'button pink', text:'Cancel', click:function () {

                } }
            ],
            closable:false,
            timeout:false
        });

    });

    $("#add-tag form").submit(function (e) {
        e.preventDefault();
        var input = $('#tag_names');
        var tagNames = input.val();
        if (tagNames.length && $.getCredible.tagCloud.length > 0) {
            input.val('');
            $.post($.getCredible.tagCloud.data('tag-cloud-path'), {tag_names:tagNames}, function (data) {
                $.getCredible.renderTagCloud($.getCredible.createWordList(data));
            });
        }
        return false;
    });

    var flashMessage = $("#flash-message");
    if(flashMessage.length > 0){
        var messageType = flashMessage.data('type');
        if(messageType == 'error'){
            noty({text: flashMessage.text(), type:'error', timeout:2000});
        }
        if(messageType == 'alert'){
            noty({text: flashMessage.text(), type:'alert', timeout:2000});
        }
        if(messageType == 'notice'){
            noty({text: flashMessage.text(), type:'success', timeout:2000});
        }
    }

    $.getCredible.updateTagCloud();
})