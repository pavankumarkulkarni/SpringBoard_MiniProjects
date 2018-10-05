/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name 
FROM  `Facilities` 
WHERE membercost !=0

/* Q2: How many facilities do not charge a fee to members? */

SELECT count(*) 
FROM  `Facilities` 
WHERE membercost !=0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities` 
WHERE membercost < monthlymaintenance * 0.2
AND membercost >0

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
FROM  `Facilities` 
WHERE facid
IN ( 1, 5 ) 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance >100
THEN  'expensive'
ELSE  'cheap'
END label
FROM  `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select firstname, surname from Members
where joindate in(
    select max(joindate) from Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
select distinct member_name, facility_name from
(
    select concat(firstname, ' ', surname) member_name,
    name facility_name
    from Bookings
    inner join Members on
    Bookings.memid = Members.memid
    inner join Facilities on
    Facilities.facid = Bookings.facid
    where name like 'Tennis Court%'
    ) a
order by member_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT f.name, CONCAT( m.firstname,  ' ', m.surname ) member_name,  
	b.slots * ( CASE WHEN b.memid =0
		THEN f.guestcost
		ELSE f.membercost
		END ) total_cost
FROM Facilities f
	INNER JOIN Bookings b 
		ON b.facid = f.facid
	INNER JOIN Members m 
		ON b.memid = m.memid
	WHERE Date(b.starttime) = '2012-09-14' and
	b.slots * ( 
		CASE WHEN b.memid =0
		THEN f.guestcost
		ELSE f.membercost
		END ) >30
	order by b.slots * ( 
		CASE WHEN b.memid =0
		THEN f.guestcost
		ELSE f.membercost
		END ) desc

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT f.name, member_name, 
	b.slots * ( CASE WHEN b.memid =0
		THEN f.guestcost
		ELSE f.membercost
		END ) total_cost
FROM Facilities f
	INNER JOIN Bookings b ON b.facid = f.facid
	INNER JOIN (
		SELECT memid, CONCAT( firstname,  ' ', surname ) member_name
			FROM Members
		)m ON b.memid = m.memid
WHERE Date(b.starttime) =  '2012-09-14'
	AND b.slots * ( 
		CASE WHEN b.memid =0
			THEN f.guestcost
		ELSE f.membercost
		END ) >30
ORDER BY b.slots * ( 
	CASE WHEN b.memid =0
	THEN f.guestcost
	ELSE f.membercost
	END ) DESC 


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
select f.name,
	   sum(b.slots* (case when b.memid = 0 then f.guestcost
         			  else f.membercost
         			  end)) tot_revenue
		from Facilities f
			inner join (
				select facid, memid,sum(slots) slots 
					from Bookings 
				group by facid, memid) b
				on b.facid = f.facid
		group by f.name
		having  sum(b.slots* (case when b.memid = 0 then f.guestcost
         			  else f.membercost
         			  end)) < 1000
		order by sum(b.slots* (case when b.memid = 0 then f.guestcost
         			  else f.membercost
         			  end)) 



