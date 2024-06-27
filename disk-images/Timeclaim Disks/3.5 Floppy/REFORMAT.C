#include	<dir.h>
#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>
#include	<process.h>

#define		LF			0x0A

struct	_index
	{
	long		OldIndex,
					NewIndex;
	unsigned
					NumberOfAccounts;
	};

struct	_part1
	{
	long		StartOfPart3,
					EndOfPart3;
	};

struct	_part2
	{
	char		SortCode[6],			/* Not NUL terminated */
					AccountNumber[8];	/* Not NUL terminated */
	short		Flag;
	long		Index;
	};

static
long		GetLong(FILE *);

static
void		ReadPart2(FILE *,struct _part2 *);
void		WritePart2(FILE *,struct _part2 *);
void		PutLong(FILE *,long);

/*============================================================================*/
void
main(int argc,char **argv)

{

struct	_index
				*Index,
				*WIndex;

struct	_part1
				OldPart1,
				NewPart1;

struct	_part2
				Part2;

FILE		*fd_i,
				*fd_o,
				*fd_t;

char		TempFileName[8];

				unsigned
int			NumberOfActiveCustomers,
				NumberOfAccounts;

int			i,c,
				ExtraAccounts;

long		CurrentIndex;

/*#
Open A:\LLOYDS.DB
Search to Part 3 of LLOYDS.DB
Count number of active records
Allocate space for 'index' structure
Open temporary output file for addresses
Search to Part 3 of LLOYDS.DB
* Loop forever
		Read a record
|		ø End of file
|       Close temporary file of addresses
|				Break
|		ø Not end of file
|				ø Not deleted
|						Note its old address
|						Write to temporary file
|						Note its new address
|				ø Deleted
|						Ignore record
|-- Continue
Write dummy Part 1 of a new file
Read a Part 2 record
* Loop until Part 2 record starts with a NUL
|   ø Part 2 record is marked as deleted
|       Ignore record
|   ø Part 2 record is NOT marked as deleted
|       Find the old address of its Part 3 record
|       Replace it with the new Part 3 address
|       Write to new file
|-- Continue
Reopen temporary addresses file
Copy to new file
Close all files
Rename original database on floppy disc to backup
Copy new file to floppy disc
Erase all temporary files
*/

if (argc != 2)
	{
	printf("\n  Usage:- REFORMAT <n>");
	printf("\n          <n> is the number of extra accounts to be allowed for");
	printf("\n          in the Database");
	exit(4);
	}

ExtraAccounts = atoi(argv[1]);

/* Open A:LLOYDS.DB */
if ((fd_i = fopen("A:LLOYDS.DB","rb")) == NULL) /* Open in BINARY mode */
	{
	printf("\n Unable to open A:LLOYDS.DB");
	exit(4);
	}

/* Search to Part 3 of LLOYDS.DB */
OldPart1.StartOfPart3 = GetLong(fd_i);
OldPart1.EndOfPart3 = GetLong(fd_i);

fseek(fd_i,OldPart1.StartOfPart3,SEEK_SET);

/* Count number of active records */

NumberOfActiveCustomers = 0;
while (ftell(fd_i) < OldPart1.EndOfPart3)
	{
	if ((c = fgetc(fd_i)) != 0xff)  ++NumberOfActiveCustomers;
	i = -1;
	while (++i < 9)
		{
		while (fgetc(fd_i) != LF)  continue;
		}
	}
printf("\n Number of Active Customers = %u",NumberOfActiveCustomers);

/* Allocate space for 'index' structure */
if ((WIndex = Index = (struct _index *)
							 malloc(NumberOfActiveCustomers * sizeof(struct _index))) == NULL)
	{
	printf("\n Out of Memory");
	exit(4);
	}
i = -1;
while (++i < NumberOfActiveCustomers)
	{
	(WIndex++)->NumberOfAccounts = 0;
	}

/* Open temporary output file */
if ((fd_t = fopen(strcpy(TempFileName,mktemp("TXXXXXX")),"wb")) == NULL)
	{
	printf("\n Cannot open temporary output file");
	exit(4);
	}

/* Search to Part 3 of LLOYDS.DB */
fseek(fd_i,OldPart1.StartOfPart3,SEEK_SET);

WIndex = Index;
while ((CurrentIndex = ftell(fd_i)) < OldPart1.EndOfPart3)
	{
	if ((c = fgetc(fd_i)) != 0xff)
		{
		WIndex->OldIndex = CurrentIndex - OldPart1.StartOfPart3;
		(WIndex++)->NewIndex = ftell(fd_t);
		fputc(c,fd_t);
		i = -1;
		while (++i < 9)
			{
			while (fputc(fgetc(fd_i),fd_t) != LF)  continue;
			}
		}
	else
		{
		i = -1;
		while (++i < 9)
			{
			while (fgetc(fd_i) != LF)  continue;
			}
		}
	}
fclose(fd_t);

fseek(fd_i,2 * sizeof(long),SEEK_SET);
ReadPart2(fd_i,&Part2);
NumberOfAccounts = 0;
while (Part2.SortCode[0] != '\0')
	{
	if (Part2.SortCode[0] != 0xff)
		{
		++NumberOfAccounts;
		i = -1;
		while (++i < NumberOfActiveCustomers)
			{
			if (Part2.Index == (*(Index + i)).OldIndex)
				{
				++(*(Index + i)).NumberOfAccounts;
				}
			}
		}
	ReadPart2(fd_i,&Part2);
	}

printf("\n         Number of Accounts = %d\n",NumberOfAccounts);

if ((fd_o = fopen("C:LLOYDS.DB","wb")) == NULL)
	{
	printf("\n Cannot open output file LLOYDS.DB");
	exit(4);
	}

PutLong(fd_o,OldPart1.StartOfPart3);
PutLong(fd_o,OldPart1.EndOfPart3);
fseek(fd_i,2 * sizeof(long),SEEK_SET);
ReadPart2(fd_i,&Part2);
while (Part2.SortCode[0] != '\0')
	{
	if (Part2.SortCode[0] != 0xff)
		{
		i = -1;
		while (++i < NumberOfActiveCustomers)
			{
			if (Part2.Index == (*(Index + i)).OldIndex)
				{
				Part2.Index = (*(Index + i)).NewIndex;
				break;
				}
			}
		WritePart2(fd_o,&Part2);
		}
	ReadPart2(fd_i,&Part2);
	}
i = -1;
while (++i < ExtraAccounts)
	{
	WritePart2(fd_o,&Part2);
	}
NewPart1.StartOfPart3 = ftell(fd_o);
if ((fd_t = fopen(TempFileName,"rb")) == NULL)
	{
	printf("\n Cannot open temporary output file for re-reading");
	exit(4);
	}
c = fgetc(fd_t);
while (c != EOF)
	{
	fputc(c,fd_o);
	c = fgetc(fd_t);
	}
NewPart1.EndOfPart3 = ftell(fd_o);
fseek(fd_o,0L,SEEK_SET);
PutLong(fd_o,NewPart1.StartOfPart3);
PutLong(fd_o,NewPart1.EndOfPart3);

fclose(fd_i);
fclose(fd_o);
fclose(fd_t);

rename("A:LLOYDS.DB","A:LLOYDS.BAK");
system("COPY /B C:LLOYDS.DB A:");
unlink("C:LLOYDS.DB");
unlink(TempFileName);

}

/*============================================================================*/
static long
GetLong(FILE *fd)
{
int			i,
				c;

long		l;

l = 0;
i = -1;
while (++i < sizeof(long))
	{
	c = fgetc(fd);
	l |= ((long)(c & 0xff) << (i * 8));
	}
return(l);
}

/*============================================================================*/
static void
PutLong(FILE *fd,long l)
{
int			i;

i = -1;
while (++i < sizeof(long))
	{
	fputc((int)(l >> (8 * i)) & 0xff,fd);
	}
}

/*============================================================================*/
static void
ReadPart2(FILE *fd,struct _part2 *p2)
{
int			i;
i = -1;
while (++i < 6)
	{
	p2->SortCode[i] = fgetc(fd);
	}
i = -1;
while (++i < 8)
	{
	p2->AccountNumber[i] = fgetc(fd);
	}
p2->Flag = fgetc(fd);
p2->Index = GetLong(fd);
}

/*============================================================================*/
static void
WritePart2(FILE *fd,struct _part2 *p2)
{
int			i;
i = -1;
while (++i < 6)
	{
	fputc((int) p2->SortCode[i] & 0xff,fd);
	}
i = -1;
while (++i < 8)
	{
	fputc((int) p2->AccountNumber[i] & 0xff,fd);
	}
fputc(p2->Flag,fd);
PutLong(fd,p2->Index);
}
/*============================================================================*/

