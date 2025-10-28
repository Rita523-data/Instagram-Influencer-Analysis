--  How many unique post types are found in the 'fact_content' table?

select distinct post_type from fact_content;

-- What are the highest and lowest recorded impressions for each post 
-- type? 

select post_type,
max(impressions) as Highest_impression ,
min(impressions) as Lowest_impression
from fact_content
group by post_type;

-- Filter all the posts that were published on a weekend in the month of 
-- March and April and export them to a separate csv file.

select * from 
fact_content 
where month(date) in (3,4)
and dayname(date) in ('saturday','sunday');

--  Create a report to get the statistics for the account. The final output 
-- includes the following fields: 
-- • month_name 
-- • total_profile_visits 
-- • total_new_followers 

select d.month_name,
		sum(a.profile_visits) as Total_profile_visits,
        sum(a.new_followers) as Total_new_followers
from dim_dates d 
join fact_account a 
on d.date = a.date
group by d.month_name;


--  Write a CTE that calculates the total number of 'likes’ for each 
-- 'post_category' during the month of 'July' and subsequently, arrange the 
-- 'post_category' values in descending order according to their total likes. 

with july_likes as (select c.post_category,
		sum(c.likes) as Total_likes
from fact_content c 
join dim_dates d 
on c.date = d.date
where d.month_name = 'July'
group by c.post_category)
select * 
from july_likes
order by Total_likes desc;

-- Create a report that displays the unique post_category names alongside 
-- their respective counts for each month. The output should have three 
-- columns:  
-- • month_name 
-- • post_category_names  
-- • post_category_count 

select d.month_name as month_name,
		c.post_category as post_category_names,
        count(post_category) as post_category_count
from fact_content c 
join dim_dates d 
on c.date = d.date
group by month_name, post_category_names;


--  What is the percentage breakdown of total reach by post type?  The final 
-- output includes the following fields: 
-- • post_type 
-- • total_reach 
-- • reach_percentage 

with cte as (
select sum(reach) as Total_reach_all
from fact_content)
select post_type,
		sum(reach) as Total_reach,
        round(sum(reach)/(select Total_reach_all from cte)*100,2) as reach_percentage
from fact_content
group by post_type;


-- 8. Create a report that includes the quarter, total comments, and total 
-- saves recorded for each post category. Assign the following quarter 
-- groupings: 
-- (January, February, March) → “Q1” 
-- (April, May, June) → “Q2” 
-- (July, August, September) → “Q3” 
-- The final output columns should consist of: 
-- • post_category 
-- • quarter 
-- • total_comments 
-- • total_saves 

select post_category,
case 
	when month(date) between 1 and 3 then 'Q1'
    when month(date) between 4 and 6 then 'Q2'
	when month(date) between 7 and 9 then 'Q3'
end as Quarter,
sum(comments) as Total_comments,
sum(saves) as Total_saves
from fact_content
group by post_category,Quarter;
 
 
-- List the top three dates in each month with the highest number of new 
-- followers. The final output should include the following columns: 
-- • month 
-- • date 
-- • new_followers 

with cte as (select d.month_name as month,
		d.date as date,
	a.new_followers as new_followers,
    rank() over(partition by d.month_name order by new_followers desc) as rnk 
from fact_account a 
join dim_dates d 
on d.date = a.date)
select month,
		date,
        new_followers
from cte
where rnk <=3
order by month,new_followers desc;


--  Create a stored procedure that takes the 'Week_no' as input and 
-- generates a report displaying the total shares for each 'Post_type'. The 
-- output of the procedure should consist of two columns: 
-- • post_type 
-- • total_shares 

select c.post_type,
		sum(shares) as Total_shares
from fact_content c 
join dim_dates d 
on d.date = c.date
where d.week_no = 'W15'
group by c.post_type
order by Total_shares desc;



