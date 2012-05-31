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
//= require easing
//= require mousewheel
//= require jquery-ui
//= require jquery_ujs
//= require jqcloud
//= require jquery.noty
//= require jquery.simplemodal
//= require jquery.tokeninput
//= require jquery.qtip
//= require jquery-progress-bubbles


Array.prototype.unique = function () {
    var o = {}, i, l = this.length, r = [];
    for (i = 0; i < l; i += 1) o[this[i]] = this[i];
    for (i in o) r.push(o[i]);
    return r;
};


$(function () {
    $.notyConf = {
        layout:'topRight',
        timeout:1000
    };

    $.getCredible = {};

    $.getCredible.displayNotification = function (type, text) {
        noty({
            text:text,
            type:type,
            timeout:$.notyConf.timeout,
            layout:$.notyConf.layout,
            onClose:function () {
            }
        });
    };

    $.getCredible.init = function () {
        $.getCredible.tagCloudPath = null;
        $.getCredible.tagCloudQtipApi = null;
        $.getCredible.currentQtipTarget = null;
        $.getCredible.tagCloudLoader = $("#tag-cloud-loader");
        $.getCredible.tagCloud = $("#tag-cloud");

        var tagNamesTextField = $("#tag_names");
        if (tagNamesTextField.length > 0) {
            tagNamesTextField.tokenInput("/tags/search", {
                method:'POST',
                queryParam:'term',
                propertyToSearch:'term',
                tokenValue:'term',
                crossDomain:false,
                theme:"facebook",
                hintText:'e.g. web design, leadership (comma separated)',
                minChars:2
            });
        }

        $("#add-tag form").submit(function (e) {
            e.preventDefault();
            var form = $(this);
            var tagNames = $("#tag_names");
            if (tagNames.length > 0) {
                tagNames = tagNames.val();
            } else {
                tagNames = ''
            }
            if (tagNames != '' && $.getCredible.tagCloud.length > 0) {
                var addTag = function () {
                    if ($.getCredible.tagCloud.data('can-tag')) {
                        $.post($.getCredible.tagCloud.data('tag-cloud-path'),
                            form.serialize(), function (data) {
                                tagNamesTextField.tokenInput("clear");
                                $.getCredible.displayNotification('success', 'You have tagged ' + $.getCredible.tagCloud.data('user').full_name + ' with ' + tagNames);
                                $.getCredible.renderTagCloud(data);
                            });
                    } else {
                        $.getCredible.displayNotification('error', 'You cannot vote for yourself')
                    }
                }

                if ($.getCredible.tagCloud.data('logged-in')) {
                    addTag();
                } else {
                    $("#tag_names_after_login").val($("#tag_names").val());
                    $.getCredible.modalApi = $('#login_dialog').modal();
                }
            }
            return false;
        });
    }

    $.getCredible.vote = function (word) {
        var word = $(word);
        var voteToggle;
        if (typeof(this.tagCloudPath) == 'string') {
            voteToggle = word.hasClass('vouche') ? '/unvote.json' : '/vote.json';
            if (this.tagCloud.data('logged-in') == false) {
                $("#word_id_after_login").val('#' + word.attr('id'));
                $("#tag_names_after_login").val($("#tag_names").val());
                $.getCredible.modalApi = $('#login_dialog').modal();
                return;
            }

            if (this.tagCloud.data('can-vote')) {
                $.post(this.tagCloudPath + '/' + word.data('user-tag-id') + voteToggle, function (data) {
                    if (data.status == 'ok') {
                        var user = $.getCredible.tagCloud.data('user');
                        var voters = $.getCredible.voterImages(data.voters);
                        word.data('score', data.score);
                        word.data('user-tag-id', data.id);
                        word.data('tagged', data.tagged);
                        word.data('rank', data.rank);
                        word.data('total', data.total);
                        word.data('voters', voters.join(''));
                        word.data('voters_count', data.voters_count);
                        $.getCredible.updateQtipContentData(word);
                        if (data.voters_count === null) {
                            $.getCredible.updateTagCloud(function () {
                                if ($.getCredible.tagCloudQtipApi) {
                                    $.getCredible.tagCloudQtipApi.hide();
                                }
                            });
                        } else {
                            if (word.hasClass('vouche')) {
                                word.removeClass("vouche").addClass("unvouche");
                                $.getCredible.displayNotification('success', 'You have unvouched for ' + user.full_name + ' on ' + word.text());
                            } else {
                                word.removeClass("unvouche").addClass("vouche");
                                $.getCredible.displayNotification('success', 'You have vouched for ' + user.full_name + ' on ' + word.text());
                            }
                        }
                        $.getCredible.tagCloudQtipApi.set('content.text', word.data('qtip-content'));
                        $('.qtip_vote').click(function () {
                            $.getCredible.vote($.getCredible.currentQtipTarget);
                            return false;
                        });
                    }
                });
            } else {
                if (!this.tagCloud.data('can-delete')) {
                    $.getCredible.displayNotification('alert', 'You can not vouche for yourself')
                }
            }
        } else {
            $.getCredible.displayNotification('error', 'You are not authorized for this action')
        }
    };

    $.getCredible.voterImages = function (voters) {
        var votersImages = [];
        $.each(voters, function (index, voter) {
            votersImages.push('<img src=' + voter.avatar + ' title=' + voter.name + ' alt=' + voter.name + '/>')
        });

        return votersImages;
    };

    $.getCredible.getWordCustomClass = function (userTag) {
        var customClass = "word ";
        customClass += this.tagCloud.data('can-delete') ? 'remove ' : '';
        if ($.getCredible.tagCloud.data('can-vote')) {
            customClass += userTag.voted ? "vouche " : "unvouche ";
        }
        return customClass;
    }

    $.getCredible.createWordList = function (data, distributionOptions) {
        var wordList = [];

        if (data.length == 0) {
            return wordList;
        }
        $.each(data, function (i, userTag) {
            var voters = $.getCredible.voterImages(userTag.voters);
            wordList.push({
                text:userTag.name,
                html:{
                    //title:userTag.name,
                    class:$.getCredible.getWordCustomClass(userTag)
                },
                weight:parseInt((userTag.score - distributionOptions.min) / distributionOptions.divisor),
                dataAttributes:{ score:userTag.score, 'user-tag-id':userTag.id,
                    rank:userTag.rank, total:userTag.total, tagged:userTag.tagged,
                    voters:voters.join(''), voters_count:userTag.voters_count},
                handlers:{click:function () {
                    $.getCredible.vote(this);
                }}
            });
        });
        return wordList;
    }

    $.getCredible.distributionOptions = function (data) {
        if (data.length === 0) {
            return {min:1, parts:1, divisor:1};
        }

        var min = data[0].score;
        var max = data[0].score;
        var votes = [];
        var parts;
        $.each(data, function (i, userTag) {
            votes.push(userTag.score)
            if (userTag.score > max) {
                max = userTag.score;
            }
            if (userTag.score < min) {
                min = userTag.score;
            }
        });
        var uniqVotes = votes.unique().length;
        if (uniqVotes < 5) {
            parts = uniqVotes;
        } else {
            parts = 5;
        }
        var divisor = (max - min) / parts;
        return {min:min, parts:parts, divisor:divisor};
    };

    $.getCredible.updateQtipContentData = function (word) {
        var rank = word.data('rank') ? '#' + word.data('rank') : 'N/A';
        var voucheUnvouche = word.hasClass('vouche') ? 'Vouche' : 'Unvouche';
        var qtipContent = '<div class="tag-wrap">' +
            '<div class="tag-score">' +
            '<p>score</p>' +
            '<p class="tag-big">' + word.data('score') + '</p>' +
            '<p class="tag-place">' + rank + ' out of ' + word.data('total') + '</p>' +
            '</div>' +
            '<div class="tag-votes">' +
            '<p>' + word.data('voters_count') +
            (word.data('voters_count') == 1 ? ' person' : ' people') +
            '  vouched for ' + word.text() + '</p>' +
            '<p>' + word.data('voters') + '</p>' +
            '</div>';
        if ($.getCredible.tagCloud.data('can-vote')) {
            qtipContent = qtipContent + '<div><a href="#" class="qtip_vote">' + voucheUnvouche + '</a></div>'
        }
        qtipContent = qtipContent + '</div>';
        word.data('qtip-content', qtipContent);
    }
    $.getCredible.renderTagCloud = function (data, tagCloudCallback) {
        var distributionOptions = $.getCredible.distributionOptions(data);
        var wordList = $.getCredible.createWordList(data, distributionOptions);
        $.getCredible.tagCloudLoader.show('fast');
        $.getCredible.tagCloud.html('');
        var growHeight = 250 + (wordList.length * 3);
        $.getCredible.tagCloud.css('height', growHeight + 'px');
        $.getCredible.tagCloud.jQCloud(wordList, {
            width:700,
            height:growHeight,
            nofollow:true,
            parts:distributionOptions.parts,
            delayedMode:true,
            afterCloudRender:function () {
                $.getCredible.tagCloudLoader.hide('fast');
                var words = $("#tag-cloud .word");
                words.each(function () {
                    var word = $(this);
                    $.getCredible.updateQtipContentData(word);
                    //if(word.hasClass('remove')){
                    word.append('<span class="icon"></span>');
                    //}
                });
                $.getCredible.tagCloudQtipApi = $('<div />').qtip(
                    {
                        content:' ', // Can use any content here :)
                        position:{
                            target:'event', // Use the triggering element as the positioning target
                            effect:false, // Disable default 'slide' positioning animation
                            my:'bottom left',
                            at:'top center'
                        },
                        show:{
                            target:words
                        },
                        hide:{
                            //target: words
                            event:'unfocus'
                        },
                        events:{
                            show:function (event, api) {
                                // Update the content of the tooltip on each show
                                $.getCredible.currentQtipTarget = $(event.originalEvent.target);
                                if ($.getCredible.currentQtipTarget.length) {
                                    api.set('content.text', $.getCredible.currentQtipTarget.data('qtip-content'));
                                    $('.qtip_vote').click(function () {
                                        $.getCredible.vote($.getCredible.currentQtipTarget);
                                        return false;
                                    });
                                }
                            },
                            hide:function (event, api) {
                                // Update the content of the tooltip on each show
                                var target = $(event.originalEvent.target);
                                if (target.hasClass('word') && $.getCredible.currentQtipTarget.attr('id') == target.attr('id')) {
                                    return false;
                                }
                            }
                        },
                        style:{
                            classes:'ui-tooltip-light ui-tooltip-rounded'
                        }

                    }).qtip('api');
                //Delegate fails
                $("#tag-cloud .remove .icon").click(function () {
                    var word = $(this).parent();
                    noty({
                        text:'Are you sure you want to delete this tag?',
                        layout:'center',
                        type:'alert',
                        buttons:[
                            {type:'button green', text:'Ok', click:function () {
                                if ($.getCredible.tagCloud.data('can-delete')) {
                                    $.post($.getCredible.tagCloudPath + '/' + word.data('user-tag-id'), { _method:'delete' }, function (data) {
                                        $.getCredible.renderTagCloud(data);
                                    });
                                }
                            } },
                            {type:'button orange', text:'Cancel', click:function () {

                            } }
                        ],
                        closable:false,
                        timeout:false
                    });
                });

                // vote callback after login via modal window
                if (typeof(tagCloudCallback) === 'function') {
                    tagCloudCallback();
                }
            }});
    }

    $.getCredible.updateTagCloud = function (tagCloudCallback) {
        if (this.tagCloud.length > 0) {
            this.tagCloudPath = this.tagCloud.data('tag-cloud-path');
            $.getJSON(this.tagCloud.data('tag-cloud-path'), function (data) {
                if ($("#bubbles_container").length > 0) {
                    guideApi.show();
                }
                $.getCredible.renderTagCloud(data, tagCloudCallback);
            });
        }
    }

    $.getCredible.ajaxPagination = function () {
        var pagination = $('#main .pagination');
        if (pagination.length > 0) {
            pagination.find('a').addClass('js-remote');
        }
    }

    $.getCredible.showFlashMessages = function () {
        var flashMessage = $("#flash-message");
        if (flashMessage.length > 0) {
            var messageType = flashMessage.data('type');
            if (messageType == 'error') {
                $.getCredible.displayNotification('error', flashMessage.text());
            }
            if (messageType == 'alert') {
                $.getCredible.displayNotification('alert', flashMessage.text());
            }
            if (messageType == 'notice') {
                $.getCredible.displayNotification('success', flashMessage.text());
            }
        }
    }

    $.getCredible.addTagOrVoteAfterLogin = function () {
        if ($("#tag_names_after_login").val() != '') {
            $("#tag_names").val($("#tag_names_after_login").val());
            $("#tag_names_after_login").val('');
            $("#add-tag form").submit();
        }
        if ($('#word_id_after_login').val() != '') {
            $.getCredible.vote($('#word_id_after_login').val());
            $('#word_id_after_login').val('');
        }
    }

    $('#login_dialog #user_sign_in .btn').click(function (e) {
        e.preventDefault();
        var form = $(this).parents('form');

        var params = form.serialize() + '&user_id=' + $.getCredible.tagCloud.data('user-name');
        $.post("/users/sign_in.json", params, function (data) {
            if (data.success) {
                $('#global-header').replaceWith(data.header);
                $('#tags').replaceWith(data.tag_cloud);
                $.getCredible.init();
                $.getCredible.updateTagCloud(function () {
                    $.getCredible.addTagOrVoteAfterLogin();
                    $.getCredible.modalApi.close();
                });
            } else {
                $.each(data.errors, function (index, text) {
                    $.getCredible.displayNotification('error', text);
                })
            }
        });
    });

    $('#login_dialog #user_sign_up .btn').click(function (e) {
        e.preventDefault();
        var form = $(this).parents('form');

        var params = form.serialize() + '&user_id=' + $.getCredible.tagCloud.data('user-name');
        $.post("/users.json", params, function (data) {
            if (data.success) {
                $('#global-header').replaceWith(data.header);
                $('#tags').replaceWith(data.tag_cloud);
                $.getCredible.init();
                $.getCredible.updateTagCloud(function () {
                    $.getCredible.addTagOrVoteAfterLogin();
                    $.getCredible.modalApi.close();
                });
            } else {
                $.each(data.errors, function (index, text) {
                    $.getCredible.displayNotification('error', text);
                })
            }
        });
    });

    $('#page').delegate('.js-remote', 'click', function (event) {
        $.ajax({
            url:$(this).attr('href'),
            success:function (data) {
                $('#main').html(data);
                $.getCredible.ajaxPagination();
                $.getCredible.showFlashMessages();
            },
            error:function () {
                $.getCredible.displayNotification('error', 'Something Went Wrong');
            }
        });
        event.preventDefault();
        return false;
    });

    //disabled qtip atm
    $('#guide-tip-disabled').qtip({
        content:{
            text:$('#guide-tip-content'),
            title:{
                text:"You are almost there !!!",
                button:true
            }
        },
        show:{
            //event: 'click',
            ready:false,
            solo:true
        },
        hide:false,
        position:{
            my:'top right',
            at:'bottom left'
        },
        style:{
            width:200,
            height:80,
            classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded'
        }
    }).click(function (event) {
            event.preventDefault();
            return false;
        });

    $('#bubbles').progressBubbles({
            bubbles:[
                {'title':'1'},
                {'title':'2'},
                {'title':'3'},
                {'title':'4'}
            ]
        }
    );

    var guideApi = $('#steps').qtip(
        {
            id:'modal', // Since we're only creating one modal, give it an ID so we can style it
            content:{
                text:$('#bubbles_container'),
                title:{
                    text:'Guide',
                    button:true
                }
            },
            position:{
                my:'center', // ...at the center of the viewport
                at:'center',
                target:$(window)
            },
            show:{
                ready:false,
                event:'click', // Show it on click...
                //solo: true, // ...and hide all other tooltips...
                modal:{
                    on:true,
                    blur:false,
                    escape:false
                }
            },
            hide:false,
            style:{
                classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded'
            },
            events:{
                show:function (event, api) {
                    $("#next_step_1").click(function () {
                        $("#step_1_form").submit();
                    });
                    $("#next_step_2").click(function () {
                        $("#step_2_form").submit();
                    });
                    $("#next_step_4").click(function () {
                        $("#step_4_form").submit();
                    });
                    $("#step_1_form, #step_2_form").submit(function () {
                        var currentStep = $(this).parent();
                        var nextStep = currentStep.next();
                        $.ajax({
                            url:$(this).attr('action') + '.json',
                            type:'POST',
                            data:$(this).serialize(),
                            dataType:'json',
                            success:function (data) {
                                if (data.status == 'error') {
                                    $.each(data.messages, function (i, message) {
                                        $.getCredible.displayNotification('error', message);
                                    })
                                } else {
                                    if (data.status == 'ok') {
                                        $.getCredible.displayNotification('success', data.messages[0]);
                                    }
                                    currentStep.slideUp(function () {
                                        $('#bubbles').progressBubbles('progress');
                                        nextStep.slideDown();
                                    });
                                }
                            }
                        });
                        return false;
                    });

                    $("#skip_step_1").click(function () {
                        $("#step_1").slideUp(function () {
                            $('#bubbles').progressBubbles('progress');
                            $("#step_2").slideDown();
                        });
                        return false;
                    });

                    $("#skip_step_2").click(function () {
                        $("#step_2").slideUp(function () {
                            $('#bubbles').progressBubbles('progress');
                            $("#step_3").slideDown();
                        });
                        return false;
                    });

                    $("#prev_step_2").click(function () {
                        $("#step_2").slideUp(function () {
                            $('#bubbles').progressBubbles('regress');
                            $("#step_1").slideDown();
                        });
                        return false;
                    });

                    $("#skip_step_3, #next_step_3").click(function () {
                        $("#step_3").slideUp(function () {
                            $('#bubbles').progressBubbles('progress');
                            $("#step_4").slideDown();
                        });
                        return false;
                    });

                    $("#prev_step_3").click(function () {
                        $("#step_3").slideUp(function () {
                            $('#bubbles').progressBubbles('regress');
                            $("#step_2").slideDown();
                        });
                        return false;
                    });

                    var step4Tags = $("#step_4_tags");
                    if (step4Tags.length > 0) {
                        step4Tags.tokenInput("/tags/search", {
                            method:'POST',
                            queryParam:'term',
                            propertyToSearch:'term',
                            tokenValue:'term',
                            crossDomain:false,
                            theme:"facebook",
                            hintText:'e.g. web design, leadership (comma separated)',
                            minChars:2
                        });
                    }

                    $("#prev_step_4").click(function () {
                        $("#step_4").slideUp(function () {
                            $('#bubbles').progressBubbles('regress');
                            $("#step_3").slideDown();
                        });
                        return false;
                    });

                    $("#step_4 form").submit(function (e) {
                        e.preventDefault();
                        var form = $(this);
                        var step4TagNames = $("#step_4_tags");
                        if (step4TagNames.length > 0) {
                            step4TagNames = step4TagNames.val();
                        } else {
                            step4TagNames = ''
                        }
                        if (step4TagNames != '' && $.getCredible.tagCloud.length > 0) {
                            var selfTag = function () {
                                $.post($.getCredible.tagCloud.data('tag-cloud-path'),
                                    form.serialize(), function (data) {
                                        step4Tags.tokenInput("clear");
                                        $.getCredible.displayNotification('success', 'You have tagged yourself with ' + step4TagNames);
                                        $.getCredible.renderTagCloud(data);
                                        api.hide();
                                        $('.token-input-dropdown-facebook').remove();
                                    });
                            }

                            if ($.getCredible.tagCloud.data('logged-in')) {
                                //$('#step_4 .token-input-list-facebook').qtip('destroy');
                                selfTag();
                            } else {
                                $.getCredible.modalApi = $('#login_dialog').modal();
                            }
                        } else {
                            $.getCredible.displayNotification('error', 'Please add tags');
                        }
                        return false;
                    });
                }
            }
        }).click(function (event) {
            event.preventDefault();
            return false;
        });
    guideApi = guideApi.qtip('api');

    // Invite user qtip
    $("li#gn-invite a").qtip({
        content:{
            // Set the text to an image HTML string with the correct src URL to the loading image you want to use
            text:'<img src="/assets/ajax_loader.gif " alt="Loading..." />',
            ajax:{
                url:'/users/invitation/new',
                success:function (data, status) {
                    var invitationQtipApi = this;
                    invitationQtipApi.set('content.text', data);
                    $('#invite_tag_names').tokenInput("/tags/search", {
                        method:'POST',
                        queryParam:'term',
                        propertyToSearch:'term',
                        tokenValue:'term',
                        crossDomain:false,
                        theme:"facebook",
                        hintText:'e.g. web design, leadership (comma separated)',
                        minChars:2
                    });
                    $("#cancel_invitation").click(function () {
                        $('#invitation_status').hide();
                        invitationQtipApi.hide();
                    });
                    $(".ui-tooltip-content").delegate('#invitation_form', 'submit', function (e) {
                        e.preventDefault();
                        $.post($(this).attr('action'),
                            $(this).serialize(), function (data) {
                                invitationQtipApi.set('content.text', data);
                                var prePopulate = [];
                                var existingTagNames = $('#invite_tag_names');
                                if (existingTagNames.length > 0 && existingTagNames.val() != '') {
                                    existingTagNames = existingTagNames.val().split(',');
                                    $.each(existingTagNames, function (index, tagName) {
                                        prePopulate.push({term:tagName});
                                    })
                                }
                                $("#cancel_invitation").click(function () {
                                    $('#invitation_status').hide();
                                    invitationQtipApi.hide();
                                });

                                $('#invite_tag_names').tokenInput("/tags/search", {
                                    method:'POST',
                                    queryParam:'term',
                                    propertyToSearch:'term',
                                    tokenValue:'term',
                                    crossDomain:false,
                                    theme:"facebook",
                                    hintText:'e.g. web design, leadership (comma separated)',
                                    minChars:2,
                                    prePopulate:prePopulate
                                });
                            });
                        return false;
                    });
                }
            },
            title:{
                text:'Send Invitation',
                button:true
            }
        },
        position:{
            at:'bottom center', // Position the tooltip above the link
            my:'top center',
            viewport:$(window), // Keep the tooltip on-screen at all times
            effect:false // Disable positioning animation
        },
        show:{
            event:'click',
            solo:true, // Only show one tooltip at a time
            modal:{
                on:true,
                blur:false,
                escape:false
            }
        },
        hide:'unfocus',
        style:{
            classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded',
            tip:false
        }
    }).click(function (event) {
            event.preventDefault();
            return false;
        });


    $('#invite_tag_names').tokenInput("/tags/search", {
        method:'POST',
        queryParam:'term',
        propertyToSearch:'term',
        tokenValue:'term',
        crossDomain:false,
        theme:"facebook",
        hintText:'e.g. web design, leadership (comma separated)',
        minChars:2
    });

    $("aside").delegate('#invitation_form', 'submit', function (e) {
        e.preventDefault();
        $.post($(this).attr('action'),
            $(this).serialize(), function (data) {
                $('#invitation_content').replaceWith(data);
                var invitationStatus = $('#invitation_status');
                if(invitationStatus.length){
                    $.getCredible.displayNotification('success', invitationStatus.text());
                }
                var prePopulate = [];
                var existingTagNames = $('#invite_tag_names');
                if (existingTagNames.length > 0 && existingTagNames.val() != '') {
                    existingTagNames = existingTagNames.val().split(',');
                    $.each(existingTagNames, function (index, tagName) {
                        prePopulate.push({term:tagName});
                    })
                }

                $('#invite_tag_names').tokenInput("/tags/search", {
                    method:'POST',
                    queryParam:'term',
                    propertyToSearch:'term',
                    tokenValue:'term',
                    crossDomain:false,
                    theme:"facebook",
                    hintText:'e.g. web design, leadership (comma separated)',
                    minChars:2,
                    prePopulate:prePopulate
                });
            });
    });
    $.getCredible.showFlashMessages();
    $.getCredible.ajaxPagination();
    $.getCredible.init();
    $.getCredible.updateTagCloud();

})
