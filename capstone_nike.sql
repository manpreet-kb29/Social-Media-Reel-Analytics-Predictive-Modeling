use capstone;
#1.
Select 
    platform, 
    sum(views) as total_views, 
    avg(engagement_rate) as average_engagement
from youtube_shorts_tiktok_trends_2025
group by platform;

#2.
Select * from 
		  (Select platform, country, sum(views)as total_views,
		  dense_rank() over(partition by platform order by sum(views) desc) as rnk
          from youtube_shorts_tiktok_trends_2025
          group by platform,country)a
          where rnk<=5;
          
#3.
Select 
   category, 
   avg(avg_watch_time_sec) as avg_watch_time_sec, 
   avg(completion_rate) as avg_completion_rate
from youtube_shorts_tiktok_trends_2025
where category in ('sports','lifestyle','fashion')
group by category;

#4.
with a as(
Select distinct author_handle, creator_tier, creator_avg_views,
dense_rank() over(order by creator_avg_views desc) as rnk
from youtube_shorts_tiktok_trends_2025
)

Select * from a 
where rnk<=10;

#5.
with a as(Select 
				hashtag, 
				sum(views) as total_views,
				dense_rank() over(order by sum(views) desc) as rnk
				from top_hashtags
				group by hashtag),

 b as(Select 
			a.hashtag,
			a.total_views,
			a.rnk,
			y.engagement_rate
from a join youtube_shorts_tiktok_trends_2025 as y
using(hashtag)
where rnk<=20
),

c as(Select *, 
	   row_number() 
       over(partition by hashtag order by engagement_rate) as pos,
       count(*) over(partition by hashtag) as n
       from b)

Select
    hashtag,
    total_views,
    ROUND(AVG(engagement_rate),4) AS median_engagement_rate
from c
Where 
    pos IN (
        FLOOR((n + 1) / 2),
        FLOOR((n + 2) / 2)
    )
GROUP BY hashtag, total_views
ORDER BY total_views DESC;

#6.
with a as (Select 
				    has_emoji,
					engagement_per_1k,
					row_number() over(partition by has_emoji order by engagement_per_1k) as pos,
					count(*) over (partition by has_emoji) as n 
					from youtube_shorts_tiktok_trends_2025)
                    
Select has_emoji, avg(engagement_per_1k) as median_engagement_per_1k
from a 
where pos in(
			 Floor((n+1)/2),
			 Floor((n+2)/2)
			)
group by has_emoji;
      
 #7.
 Select 
		publish_dayofweek, 
		upload_hour,
        avg(views) as avg_views,
        Round(avg(completion_rate),4) as avg_completion_rate
from youtube_shorts_tiktok_trends_2025
group by publish_dayofweek,upload_hour
order by publish_dayofweek;

#8.
with a as(Select 
		engagement_velocity,
        trend_type,
        row_number() over(partition by trend_type order by engagement_velocity) as pos,
        count(*) over(partition by trend_type) as n
from youtube_shorts_tiktok_trends_2025),

c as (Select trend_type, avg(engagement_velocity) as median_engagement_velocity
from a
where pos in (	
				Floor((n+1)/2),
                Floor((n+2)/2)
			  )
group by trend_type),

b as(Select 
		trend_duration_days,
        trend_type,
        row_number() over(partition by trend_type order by trend_duration_days) as pos,
        count(*) over(partition by trend_type) as n
from youtube_shorts_tiktok_trends_2025),

d as(Select trend_type, avg(trend_duration_days) as median_trend_duration
from b
where pos in (	
				Floor((n+1)/2),
                Floor((n+2)/2)
			  )
group by trend_type)

Select 
		c.trend_type,
        c.median_engagement_velocity,
        d.median_trend_duration
from c join d
using(trend_type);

#9.
Select 
		Case 
			when device_brand LIKE '%Apple%'
			OR device_brand LIKE '%iPhone%'
			OR device_brand LIKE '%iPad%'
			then 'iOS'
			else 'Android'
			end as fixed_device_type,
        device_brand,
        avg(completion_rate) as avg_completion_rate
from youtube_shorts_tiktok_trends_2025
group by fixed_device_type,device_brand;

#10.
with a as(Select 
		traffic_source, 
        completion_rate,
        row_number() over(partition by traffic_source order by completion_rate) as pos,
        count(*) over(partition by traffic_source) as n
from youtube_shorts_tiktok_trends_2025)

Select traffic_source, round(avg(completion_rate),3) as median_completion_rate
from a 
where pos in (
				floor((n+1)/2),
                floor((n+2)/2)
			 )
group by traffic_source;

#11.
Select 
		event_season,
        sum(views) as total_views,
        round(avg(engagement_rate),4) as avg_engagement_rate
from youtube_shorts_tiktok_trends_2025
group by event_season
order by sum(views) desc;

#12.
SELECT 
   
    engagement_total AS stored_engagement,
    
    (
        COALESCE(likes,0) +
        COALESCE(comments,0) +
        COALESCE(shares,0) +
        COALESCE(saves,0)
    ) AS calculated_engagement

FROM youtube_shorts_tiktok_trends_2025

WHERE engagement_total !=
(
    COALESCE(likes,0) +
    COALESCE(comments,0) +
    COALESCE(shares,0) +
    COALESCE(saves,0)
);










          