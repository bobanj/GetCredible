class TagsController < ApplicationController

  def search
    render :json => Tag.search(params['term'])
  end

  def preview
    render json:  {
        "url" => "http://www.youtube.com/watch?v=B-m6JDYRFvk",
        "type" => "html",
        "cache_age" => 86400,
        "safe" => true,

        "title" => "Coder Girl",
        "description" => "An ode to female programmers.\r\n\r\nEP Available on iTunes!\r\n
                    http://bit.ly/4sebjr\r\n
                    Find more great music @ http://dalechase.com  http://twitter.com/daleochase\r\n
                    Song lyrics here: http://bit.ly/7eOilA",

        "author_name" => "dalechase",
        "author_url" => "http://www.youtube.com/user/dalechase",

        "content" => nil,

    "embeds" => [],

        "images" => [{"height" => 360,
        "url" => "http://i3.ytimg.com/vi/B-m6JDYRFvk/hqdefault.jpg",
        "width" => 480}],
        "object" => {"height" => 360,
        "html" => "<object width='640' height='360'>
                           <param name='movie' value='http://www.youtube.com/v/B-m6JDYRFvk?fs=1'>
                           <param name='allowFullScreen' value='true'>
                           <param name='allowscriptaccess' value='always'>
                           <embed src='http://www.youtube.com/v/B-m6JDYRFvk?fs=1'
                                  type='application/x-shockwave-flash'
                                  width='640' height='360' allowscriptaccess='always'
                                  allowfullscreen='true'></embed>
                        </object>",
        "type" => "video",
        "width" => 640},

        "place" => {},

        "event" => {}
    }
  end
end
