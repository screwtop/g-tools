-- OK, let's have a go at a G-code disassembler.  Now that I have a slightly better understanding of the language and syntax and semantics...
-- SQLite3 syntax, I guess...
-- The core will basically be a database, I guess.  One thing to consider is that different codes can mean different things to different machine controllers.

-- The G set of codes/word are preparatory codes or commands.

create table Word
(
	Word	char(1),
	Title	varchar(50),

	constraint Word_PK primary key (Word)	
);


insert into Word (Word, Title) values ('G', '[G]eneral function/prepared command'); -- [G]eneral function; prepared code/command.

insert into Word (Word, Title) values ('N', 'Line [N]umber');	-- Line [N]umber - how to handle addresses?

insert into Word (Word, Title) values ('S', '[S]peed of spindle');

insert into Word (Word, Title) values ('X', '[X] axis');
insert into Word (Word, Title) values ('Y', '[Y] axis');
insert into Word (Word, Title) values ('Z', '[Z] axis');

insert into Word (Word, Title) values ('I', '');
insert into Word (Word, Title) values ('J', '');
insert into Word (Word, Title) values ('K', '');

insert into Word (Word, Title) values ('P', '[P]arameter');

insert into Word (Word, Title) values ('T', '[T]ool selection');

insert into Word (Word, Title) values ('E', '[E]xtrude'); -- for 3D printers

-- TODO: add more


-- Hmm, do we need to distinguish between codes (addressed words that specify some command, like G and M) and non-addressed words (like X and S)?
-- And what about decimal sub-codes?!

create table Code
(
	Word	char(1),
	Address char(2),
	Title	varchar(50),
	Description	varchar(2000),
	Milling boolean,
	Turning boolean,
	Modal boolean,

	constraint Code_PK primary key (Word, Address),
	constraint Code_Word_FK foreign key (Word) references Word (Word)
);

insert into Code (Word, Address, Title) values ('G', '00', 'Rapid positioning');
insert into Code (Word, Address, Title) values ('G', '01', 'Linear interpolation'); -- AKA co-ordinated move?
insert into Code (Word, Address, Title) values ('G', '02', 'Circular interpolation, clockwise');
insert into Code (Word, Address, Title) values ('G', '03', 'Circular interpolation, anticlockwise');
insert into Code (Word, Address, Title) values ('G', '04', 'Dwell');
insert into Code (Word, Address, Title) values ('G', '05', 'Cubic spline interpolation');
insert into Code (Word, Address, Title) values ('G', '17', 'XY plane selection');
insert into Code (Word, Address, Title) values ('G', '18', 'ZX plane selection');
insert into Code (Word, Address, Title) values ('G', '19', 'YZ plane selection');
insert into Code (Word, Address, Title) values ('G', '20', 'Programming in inches');
insert into Code (Word, Address, Title) values ('G', '21', 'Programming in mm');
insert into Code (Word, Address, Title) values ('G', '28', 'Return to home position');
insert into Code (Word, Address, Title) values ('G', '40', 'Disable cutter compensation');
insert into Code (Word, Address, Title) values ('G', '43', 'Tool length offset');
insert into Code (Word, Address, Title) values ('G', '49', 'Cancel tool length compensation');
insert into Code (Word, Address, Title) values ('G', '53', 'Move in machine co-ordinates');
insert into Code (Word, Address, Title) values ('G', '54', 'Select co-ordinate system 1');
insert into Code (Word, Address, Title) values ('G', '55', 'Select co-ordinate system 2');
insert into Code (Word, Address, Title) values ('G', '56', 'Select co-ordinate system 3');
insert into Code (Word, Address, Title) values ('G', '57', 'Select co-ordinate system 4');
insert into Code (Word, Address, Title) values ('G', '58', 'Select co-ordinate system 5');
insert into Code (Word, Address, Title) values ('G', '59', 'Select co-ordinate system 6');
insert into Code (Word, Address, Title) values ('G', '61', 'Exact path mode');
insert into Code (Word, Address, Title) values ('G', '64', 'Path blending: best speed possible');
insert into Code (Word, Address, Title) values ('G', '80', 'Cancel modal motion (no motion)');
insert into Code (Word, Address, Title) values ('G', '90', 'Absolute programming');
insert into Code (Word, Address, Title) values ('G', '91', 'Incremental programming');
insert into Code (Word, Address, Title) values ('G', '96', 'Constant surface speed');
insert into Code (Word, Address, Title) values ('G', '97', 'Constant spindle speed');

insert into Code (Word, Address, Title) values ('M', '00', 'Pause/Compulsory stop');
insert into Code (Word, Address, Title) values ('M', '01', 'Pause (if stop switch on)');
insert into Code (Word, Address, Title) values ('M', '02', 'End of program');
insert into Code (Word, Address, Title) values ('M', '03', 'Spindle on (clockwise)');
insert into Code (Word, Address, Title) values ('M', '04', 'Spindle on (anticlockwise)');
insert into Code (Word, Address, Title) values ('M', '05', 'Spindle stop');
insert into Code (Word, Address, Title) values ('M', '06', 'Tool change');
insert into Code (Word, Address, Title) values ('M', '07', 'Turn mist coolant on');
insert into Code (Word, Address, Title) values ('M', '08', 'Turn flood coolant on');
insert into Code (Word, Address, Title) values ('M', '09', 'Turn all coolant off');
insert into Code (Word, Address, Title) values ('M', '30', 'End of program, with return to program top/pallet swap');


-- Modal groups (sets of commands of which only one member may be active at a time)
-- http://www.smithy.com/cnc-reference-info/language-overview/word/modal-groups/page/9
-- Note also that no more than 4 M commands may be used per block (why?).

create table Modal_Group
(
	Modal_Group_Name varchar2(200),
	constraint Modal_Group_PK primary key (Modal_Group_Name)
	-- Members of a modal group seem to be all of the same leading word, but is that always the case? If so, could perhaps include Word as an element of the PK.
);

insert into Modal_Group (Modal_Group_Name) values ('Plane Selection');
insert into Modal_Group (Modal_Group_Name) values ('Distance Mode');
insert into Modal_Group (Modal_Group_Name) values ('Feed Rate Mode');
insert into Modal_Group (Modal_Group_Name) values ('Spindle Turning');
-- TODO: more...

create table Modal_Group_Element
(
	Modal_Group_Name	varchar2(200),
	Member_Word	char(1),
	Member_Address	char(2),
	constraint Modal_Group_Element_PK primary key (Modal_Group_Name, Member_Word, Member_Address),
	constraint Modal_Group_Element_Group_FK foreign key (Modal_Group_Name) references Modal_Group
);

insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Plane Selection', 'G', '17');
insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Plane Selection', 'G', '18');
insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Plane Selection', 'G', '19');

insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Distance Mode', 'G', '90');
insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Distance Mode', 'G', '91');

insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Feed Rate Mode', 'G', '93');
insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Feed Rate Mode', 'G', '94');

insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Spindle Turning', 'M', '03');
insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Spindle Turning', 'M', '04');
insert into Modal_Group_Element (Modal_Group_Name, Member_Word, Member_Address) values ('Spindle Turning', 'M', '05');

-- TODO: add more...


-- Suggested preamble (Smithy): G17/18/19 G20/21 G40 G49 G54 G80 G90/91 G94/G93

