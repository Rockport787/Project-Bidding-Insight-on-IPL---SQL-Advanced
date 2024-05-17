/*1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
*/
SELECT 
    ipl_bidder_details.BIDDER_ID,
    ipl_bidder_details.BIDDER_NAME,
    COUNT(ipl_bidding_details.BIDDER_ID) AS TOTAL_BIDS,
    COUNT(CASE WHEN ipl_match.MATCH_WINNER = ipl_bidding_details.BID_TEAM THEN 1 END) AS WINS,
    (COUNT(CASE WHEN ipl_match.MATCH_WINNER = ipl_bidding_details.BID_TEAM THEN 1 END) / COUNT(ipl_bidding_details.BIDDER_ID)) * 100 AS WIN_PERCENTAGE
FROM 
    ipl_bidding_details
JOIN 
    ipl_bidder_details ON ipl_bidding_details.BIDDER_ID = ipl_bidder_details.BIDDER_ID
JOIN 
    ipl_match_schedule ON ipl_bidding_details.SCHEDULE_ID = ipl_match_schedule.SCHEDULE_ID
JOIN 
    ipl_match ON ipl_match_schedule.MATCH_ID = ipl_match.MATCH_ID
GROUP BY 
    ipl_bidder_details.BIDDER_ID
ORDER BY 
    WIN_PERCENTAGE DESC;

/*2.	Display the number of matches conducted at each stadium with the stadium name and city.
*/
SELECT 
    s.STADIUM_NAME,
    s.CITY,
    COUNT(ms.MATCH_ID) AS MATCHES_CONDUCTED
FROM 
    ipl_match_schedule ms
JOIN 
    ipl_stadium s ON ms.STADIUM_ID = s.STADIUM_ID
GROUP BY 
    s.STADIUM_NAME, s.CITY;
    
/*3.In a given stadium, what is the percentage of wins by a team that has won the toss?

*/
SELECT 
    s.STADIUM_NAME,
    s.CITY,
    COUNT(*) AS TOTAL_MATCHES,
    SUM(CASE WHEN m.TOSS_WINNER = m.MATCH_WINNER THEN 1 ELSE 0 END) AS MATCHES_WON_BY_TOSS_WINNER,
    (SUM(CASE WHEN m.TOSS_WINNER = m.MATCH_WINNER THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS WIN_PERCENTAGE
FROM 
    ipl_match m
JOIN 
    ipl_match_schedule ms ON m.MATCH_ID = ms.MATCH_ID
JOIN 
    ipl_stadium s ON ms.STADIUM_ID = s.STADIUM_ID
GROUP BY 
    s.STADIUM_NAME, s.CITY;
    
/*4.	Show the total bids along with the bid team and team name.*/

SELECT 
    bd.BIDDER_ID,
    bd.SCHEDULE_ID,
    bd.BID_DATE,
    bd.BID_STATUS,
    bd.BID_TEAM,
    t.TEAM_NAME
FROM 
    ipl_bidding_details bd
JOIN 
    ipl_team t ON bd.BID_TEAM = t.TEAM_ID;
    
/*5.	Show the team ID who won the match as per the win details.
*/
SELECT 
 TEAM_ID1
FROM 
ipl_match
WHERE 
	TEAM_ID1=Match_winner
union
SELECT 
 TEAM_ID2
FROM 
ipl_match
WHERE 
	TEAM_ID2=Match_winner;
    
/*6.	Display the total matches played, total matches won and total matches lost by the team along with its team name.

*/

SELECT 
    t.TEAM_NAME,
    COUNT(ms.MATCH_ID) AS TOTAL_MATCHES_PLAYED,
    COALESCE(SUM(CASE WHEN m.MATCH_WINNER = t.TEAM_ID THEN 1 ELSE 0 END), 0) AS TOTAL_MATCHES_WON,
    COALESCE(SUM(CASE WHEN m.MATCH_WINNER != t.TEAM_ID THEN 1 ELSE 0 END), 0) AS TOTAL_MATCHES_LOST
FROM 
    ipl_team t
LEFT JOIN 
    ipl_match m ON t.TEAM_ID = m.MATCH_WINNER OR t.TEAM_ID = m.TEAM_ID1 OR t.TEAM_ID = m.TEAM_ID2
LEFT JOIN 
    ipl_match_schedule ms ON m.MATCH_ID = ms.MATCH_ID
GROUP BY 
    t.TEAM_NAME;
    
/*7.	Display the bowlers for the Mumbai Indians team.*/
SELECT
    p.PLAYER_NAME
FROM
    ipl_player p
JOIN
    ipl_team_players tp ON p.PLAYER_ID = tp.PLAYER_ID
JOIN
    ipl_team t ON tp.TEAM_ID = t.TEAM_ID
WHERE
    t.TEAM_NAME = 'Mumbai Indians'
    AND tp.PLAYER_ROLE = 'Bowler';

/*8.	How many all-rounders are there in each team, Display the teams with more than 4 
all-rounders in descending order.
*/

SELECT
    t.TEAM_NAME,
    COUNT(tp.PLAYER_ID) AS all_rounders_count
FROM
    ipl_team t
JOIN
    ipl_team_players tp ON t.TEAM_ID = tp.TEAM_ID
JOIN
    ipl_player p ON tp.PLAYER_ID = p.PLAYER_ID
WHERE
    tp.PLAYER_ROLE = 'All-Rounder'
GROUP BY
    t.TEAM_NAME
HAVING
    all_rounders_count > 4
ORDER BY
    all_rounders_count DESC;

/*Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in M. Chinnaswamy Stadium bidding year-wise.
 Note the total bidders’ points in descending order and the year is the bidding year.
               Display columns: bidding status, bid date as year, total bidder’s points
*/
SELECT 
    ibd.BID_STATUS AS bidding_status,
    YEAR(ibd.BID_DATE) AS bid_year,
    SUM(ibp.TOTAL_POINTS) AS total_bidders_points
FROM 
    ipl_bidding_details ibd
JOIN 
    ipl_bidder_points ibp ON ibd.BIDDER_ID = ibp.BIDDER_ID
JOIN 
    ipl_match_schedule ims ON ibd.SCHEDULE_ID = ims.SCHEDULE_ID
JOIN 
    ipl_match im ON ims.MATCH_ID = im.MATCH_ID
JOIN 
    ipl_stadium ist ON ims.STADIUM_ID = ist.STADIUM_ID
JOIN 
    ipl_team it ON ibd.BID_TEAM = it.TEAM_ID
WHERE 
    it.TEAM_NAME = 'CSK'
    AND im.MATCH_WINNER = it.TEAM_ID
    AND ist.STADIUM_NAME = 'M. Chinnaswamy Stadium'
GROUP BY 
    ibd.BID_STATUS, YEAR(ibd.BID_DATE)
ORDER BY 
    total_bidders_points DESC, bid_year;

select * from ipl_stadium;

/* 10.	Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
Note 
1. Use the performance_dtls column from ipl_player to get the total number of wickets
 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
3.	Do not use joins in any cases.
4.	Display the following columns teamn_name, player_name, and player_role.
*/

SELECT 
    it.TEAM_NAME,
    ip.PLAYER_NAME,
    itp.PLAYER_ROLE
FROM 
    ipl_player ip,
    ipl_team it,
    ipl_team_players itp
WHERE 
    itp.PLAYER_ID = ip.PLAYER_ID
    AND itp.TEAM_ID = it.TEAM_ID
    AND itp.PLAYER_ROLE IN ('Bowler', 'All-Rounder')
    AND ip.PLAYER_ID IN (
        SELECT 
            PLAYER_ID
        FROM 
            ipl_player
        ORDER BY 
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(PERFORMANCE_DTLS, 'Wickets:', -1), 'w', 1) AS UNSIGNED) DESC
    )
ORDER BY 
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip.PERFORMANCE_DTLS, 'Wickets:', -1), 'w', 1) AS UNSIGNED) DESC
    
/*11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
*/
SELECT
    bd.BIDDER_ID,
    bd.BIDDER_NAME,
    ROUND((COUNT(CASE WHEN m.TEAM_ID1 = m.TOSS_WINNER THEN 1 END) + COUNT(CASE WHEN m.TEAM_ID2 = m.TOSS_WINNER THEN 1 END)) / (COUNT(*) * 100), 2) AS toss_win_percentage
FROM
    ipl_bidder_details bd
LEFT JOIN
    ipl_bidding_details bid ON bd.BIDDER_ID = bid.BIDDER_ID
LEFT JOIN
    ipl_match_schedule ms ON bid.SCHEDULE_ID = ms.SCHEDULE_ID
LEFT JOIN
    ipl_match m ON ms.MATCH_ID = m.MATCH_ID
GROUP BY
    bd.BIDDER_ID, bd.BIDDER_NAME
ORDER BY
    toss_win_percentage DESC;

    
/*12.	find the IPL season which has a duration and max duration.
Output columns should be like the below:
 Tournment_ID, Tourment_name, Duration column, Duration
*/
SELECT
    TOURNMT_ID,
    TOURNMT_NAME,
    CONCAT(DATEDIFF(TO_DATE, FROM_DATE), ' days') AS Duration_Column,
    DATEDIFF(TO_DATE, FROM_DATE) AS Duration
FROM
    ipl_tournament
ORDER BY
    Duration ASC
LIMIT 1
union
select
    TOURNMT_ID,
    TOURNMT_NAME,
    CONCAT(DATEDIFF(TO_DATE, FROM_DATE), ' days') AS Duration_Column,
    DATEDIFF(TO_DATE, FROM_DATE) AS Duration
FROM
    ipl_tournament
ORDER BY
    Duration DESC
LIMIT 1;

/*13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order.
Note: Display the following columns:
1.	Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points
Only use joins for the above query queries.
*/

SELECT
    bd.BIDDER_ID,
    br.BIDDER_NAME,
    YEAR(bd.BID_DATE) AS Bid_Year,
    MONTH(bd.BID_DATE) AS Bid_Month,
    SUM(bp.TOTAL_POINTS) AS Total_Points
FROM (ipl_bidder_details br JOIN
    ipl_bidding_details bd on br.BIDDER_ID=bd.BIDDER_ID)
JOIN
    ipl_bidder_points bp ON bd.BIDDER_ID = bp.BIDDER_ID
WHERE
    YEAR(bd.BID_DATE) = 2017
GROUP BY
    bd.BIDDER_ID,
    br.BIDDER_NAME,
    YEAR(bd.BID_DATE),
    MONTH(bd.BID_DATE)
ORDER BY
    Total_Points DESC,
    Bid_Year ASC,
    Bid_Month ASC;
    
/*14.	Write a query for the above question using sub-queries by having the same constraints as the above question
*/
SELECT
    bd.BIDDER_ID,
    bd.BIDDER_NAME,
    YEAR(bd.BID_DATE) AS Bid_Year,
    MONTH(bd.BID_DATE) AS Bid_Month,
    COALESCE(total_points, 0) AS Total_Points
FROM
    ipl_bidder_details bd
LEFT JOIN (
    SELECT
        BIDDER_ID,
        YEAR(BID_DATE) AS Bid_Year,
        MONTH(BID_DATE) AS Bid_Month,
        SUM(TOTAL_POINTS) AS total_points
    FROM
        ipl_bidding_details
    WHERE
        YEAR(BID_DATE) = 2017
    GROUP BY
        BIDDER_ID,
        YEAR(BID_DATE),
        MONTH(BID_DATE)
) AS points ON bd.BIDDER_ID = points.BIDDER_ID
           AND YEAR(bd.BID_DATE) = points.Bid_Year
           AND MONTH(bd.BID_DATE) = points.Bid_Month
ORDER BY
    total_points DESC,
    Bid_Year ASC,
    Bid_Month ASC;

/*15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
Output columns should be:
like
Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;
*/
WITH Bidders_Total_Points AS (
    SELECT
        bd.BIDDER_ID,
        SUM(bp.TOTAL_POINTS) AS Total_Points
    FROM
        ipl_bidder_details bd
    INNER JOIN ipl_bidding_details bid ON bd.BIDDER_ID = bid.BIDDER_ID
    INNER JOIN ipl_bidder_points bp ON bd.BIDDER_ID = bp.BIDDER_ID
    WHERE
        YEAR(bid.BID_DATE) = 2018
    GROUP BY
        bd.BIDDER_ID
)
SELECT
    Bidder_ID,
    Total_Points,
    CASE
        WHEN RANK() OVER (ORDER BY Total_Points DESC) <= 3 THEN 'Highest_3_Bidders'
        ELSE 'Lowest_3_Bidders'
    END AS Ranking
FROM
    (
        SELECT
            BIDDER_ID,
            Total_Points
        FROM
            Bidders_Total_Points
        UNION ALL
        SELECT
            BIDDER_ID,
            Total_Points
        FROM
            Bidders_Total_Points
    ) AS Combined_Bidders
ORDER BY
    CASE
        WHEN RANK() OVER (ORDER BY Total_Points DESC) <= 3 THEN 1
        ELSE 2
    END,
    Total_Points DESC;

/*16.	Create two tables called Student_details and Student_details_backup. (Additional Question - Self Study is required)

Table 1: Attributes 		Table 2: Attributes
Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

*/


CREATE TABLE Student_details (
    Student_id INT PRIMARY KEY,
    Student_name VARCHAR(50),
    Mail_id VARCHAR(100),
    Mobile_no BIGINT
);


CREATE TABLE Student_details_backup (
    Student_id INT,
    Student_name VARCHAR(50),
    Mail_id VARCHAR(100),
    Mobile_no BIGINT,
    Backup_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

/*trigger to automatically insert details into the backup tables*/
DELIMITER //
CREATE TRIGGER StudentDetails_Backup_Trigger
AFTER INSERT ON Student_details
FOR EACH ROW
BEGIN
    INSERT INTO Student_details_backup (Student_id, Student_name, Mail_id, Mobile_no)
    VALUES (NEW.Student_id, NEW.Student_name, NEW.Mail_id, NEW.Mobile_no);
END;
//
DELIMITER ;

/*to test the trigger with transactions*/
START TRANSACTION;

INSERT INTO Student_details (Student_id, Student_name, Mail_id, Mobile_no)
VALUES (1, 'John Doe', 'john@example.com', 1234567890);

COMMIT;
