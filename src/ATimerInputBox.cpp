#include <QKeyEvent> 
#include <QMouseEvent>
#include <QClipboard>
#include <QLineEdit>
#include "ATimerInputBox.h"
#include "DataModel/opendatafile.h"
#include "myapplication.h"
#include <string>
#include <cmath>

ATimerInputBox::ATimerInputBox()
{
	this->TimerDialog = new ATimerDialog();
	this->RealDialog = new ARealDialog();
	this->Type = Cursor;
	this->Model = Ofset;
	this->Frequency = 0;

	// Time definition 
	this->SetModelDefault();
}

void ATimerInputBox::SetModel(ModelInput typeModel)
{
	this->Model = typeModel;
}

void ATimerInputBox::ChangeToPositionType()
{
	this->Type = Position;	
}

void ATimerInputBox::DefineFrequency(double frequency)
{
	this->Frequency = frequency;
}


void ATimerInputBox::mousePressEvent(QMouseEvent* event)
{
	if(event->button() == Qt::RightButton)
	{
		  this->OpenTimerDialog();
	}
}

void ATimerInputBox::keyPressEvent(QKeyEvent* event)
{
	QString value = this->text();

	if((event->key() == Qt::Key_V))
	{
	    value = MyApplication::clipboard()->text();
		this->setText(value);
	}

	//  delete the value
	if ( (event->key() == Qt::Key_Backspace) && (this->Type == Position) )
	{
		value = "";
		this->setText(value);
	}

	if ( (event->key() == Qt::Key_Delete) && (this->Type == Position))
	{
		value = "";
		this->setText(value);
	}

	if(  (event->key() == Qt::Key_C) || (event->key() == Qt::Key_Control))
	{
		MyApplication::clipboard()->setText(value);;
	}

	// detected the number in the box
	if (event->key() == Qt::Key_0
		|| Qt::Key_1
		|| Qt::Key_2
		|| Qt::Key_3
		|| Qt::Key_4
		|| Qt::Key_5
		|| Qt::Key_6
		|| Qt::Key_7
		|| Qt::Key_8
		|| Qt::Key_9
		&& this->Type == Position)
	{
		if (event->key() == Qt::Key_0)
		{
			value = value + "0";
		}

		if (event->key() == Qt::Key_1)
		{
			value = value + "1";
		}
		
		if (event->key() == Qt::Key_2)
		{
			value = value + "2";
		}
			
		if (event->key() == Qt::Key_3)
		{
			value = value + "3";
		}
			
		if (event->key() == Qt::Key_4)
		{
			value = value + "4";
		}
	
		if (event->key() == Qt::Key_5)
		{
			value = value + "5";
		}

		if (event->key() == Qt::Key_6)
		{
			value = value + "6";
		}

		if (event->key() == Qt::Key_7) 
		{
			value = value + "7";
		}

		if (event->key() == Qt::Key_8) 
		{
			value = value + "8";
		}

		if (event->key() == Qt::Key_9) 
		{
			value = value + "9";
		}			
	}

	value = this->ValidateOperator(value, event);

	// If the sample mode was chosse do this
	if (this->Model == Sample)
	{
		this->setText(value);

		if ( (event->key() == Qt::Key_Enter)  && (this->Type == Position) )
		{
			emit OpenDataFile::infoTable.positionChanged(CoverterSampleToInt(this->text()), OpenDataFile::infoTable.getPositionIndicator());
		}
	}

	// If the user do not put the D(day operator) do this
	if ( (this->Model == Ofset) && (this->Type == Position) && !this->VerifyOperatorD(value) )
	{
		if (this->ModelDefault)
		{
			int numberOfCharater = value.count();

			switch (numberOfCharater)
			{
			case 2:
				value = value + ":";
				break;
			case 5:
				value = value + ":";
				break;
			case 8:
				value = value + ".";
				break;
			default:
				break;
			}

			if (numberOfCharater > 12)
			{
				value = value.left(12);
			}

			this->setText(value);

			if (event->key() == Qt::Key_Enter && this->Type == Position)
			{
				int position = ConvertTimeToSamplePosition(this->text());
				emit OpenDataFile::infoTable.positionChanged(position, OpenDataFile::infoTable.getPositionIndicator());
			}
		}
	}

	// If the operator D is operattivy
	if( (this->Model == Ofset) && (this->Type == Position) && this->VerifyOperatorD(value) )
	{
		if (this->ModelDefault)
		{
			int numberOfCharater = value.count();

			switch (numberOfCharater)
			{
			case 2:
				value = value + " ";
				break;
			case 5:
				value = value + ":";
				break;
			case 8:
				value = value + ":";
				break;
			case 11:
				value = value + ".";
			default:
				break;
			}

			if (numberOfCharater > 15)
			{
				value = value.left(15);
			}

			this->setText(value);

			if (event->key() == Qt::Key_Enter && this->Type == Position)
			{
				int position = ConvertTimeToSamplePositionOperatorD(this->text());
				emit OpenDataFile::infoTable.positionChanged(position, OpenDataFile::infoTable.getPositionIndicator());
			}
		}
	}

	if ((this->Model == Ofset) && (this->Type == Position))
	{
		// Model seconds
		if (this->ModelSeconds)
		{
			this->setText(value);
			// The position is important for not use the cursor update
			if (event->key() == Qt::Key_Enter && this->Type == Position)
			{
				int position = CalculatePositionFromSeconds(this->text().remove(' ').remove('S').remove("M"), Frequency);
				emit OpenDataFile::infoTable.positionChanged(position, OpenDataFile::infoTable.getPositionIndicator());
			}
		}

		// Model 
		if (this->ModelMinutes)
		{
			this->setText(value);

			// the position is important for not use the cursor update
			if ((event->key() == Qt::Key_Enter) && (this->Type == Position))
			{
				int position = CalculatePositionFromMinutes(this->text().remove(' ').remove('S').remove("M"), Frequency);
				emit OpenDataFile::infoTable.positionChanged(position, OpenDataFile::infoTable.getPositionIndicator());
			}
		}

		// Define defalult
		if ((event->key() == Qt::Key_H) && (this->Model == Ofset))
		{
			this->SetModelDefault();
			emit this->ChangedBaseModel(0);
		}

		// Define the tip for seconds 
		if ((event->key() == Qt::Key_S) && (this->Model == Ofset))
		{
			this->SetModelSeconds();
			// Change the mode how operate the time 
			emit this->ChangedBaseModel(1);
		}

		if ((event->key() == Qt::Key_M) && (this->Model == Ofset))
		{
			this->SetModelMinutes();
			emit this->ChangedBaseModel(2);
		}
	}

}

void ATimerInputBox::OpenTimerDialog()
{
	/*
	if (this->Type == Position)
	{
		if (this->Model == Ofset)
            TimerDialog->showNormal();myapplication

		if (this->Model == Real)
			RealDialog->showNormal();
	}
	*/
}

int ATimerInputBox::CoverterSampleToInt(QString valueText)
{
	if(!valueText.isEmpty())
	{
		int position = 0;
		position = valueText.toInt();
		return position;
	}
	else 
	{
		return 0;
	}
}

int ATimerInputBox::ConvertTimeToSamplePosition(QString valueText)
{
	if(valueText.isEmpty())
	{
		return 0;
	}
	else 
	{
		int numberOfCharater = valueText.count();
		int positionSample = 0;

		if(numberOfCharater == 1)
		{
			int time = valueText.toInt();
			positionSample = CalculatePositionSampleOnTime(time, this->Frequency);
		}

		if(numberOfCharater == 3)
		{
			int time = valueText.mid(0, 2).toInt();
			positionSample = CalculatePositionSampleOnTime(time, this->Frequency);
		}

		if(numberOfCharater == 4)
		{
			int minuts = valueText.mid(0, 2).toInt() * 60;
			int seconds = valueText.mid(3, 1).toInt();
			int time = minuts + seconds;
			positionSample = CalculatePositionSampleOnTime(time, this->Frequency);
		}

		if(numberOfCharater == 6)
		{
			int minuts = valueText.mid(0, 2).toInt() * 60;
			int seconds = valueText.mid(3, 2).toInt();
			int time = minuts + seconds;
			positionSample = CalculatePositionSampleOnTime(time, this->Frequency);
		}

		if (numberOfCharater == 7) 
		{
			int hours = valueText.mid(0, 2).toInt() * 3600;
			int minuts = valueText.mid(3, 2).toInt() * 60;
			int seconds = valueText.mid(6, 1).toInt();
			int time = hours + minuts + seconds;
			positionSample = CalculatePositionSampleOnTime(time, this->Frequency);
		}

		if (numberOfCharater == 9)
		{
			int hours = valueText.mid(0, 2).toInt() * 3600;
			int minuts = valueText.mid(3, 2).toInt() * 60;
			int seconds = valueText.mid(6, 2).toInt();
			int time = hours + minuts + seconds;
			positionSample = CalculatePositionSampleOnTime(time, this->Frequency);
		}

		if (numberOfCharater == 10) 
		{

			double hours = valueText.mid(0, 2).toDouble() * 3600 ;
			double minuts = valueText.mid(3, 2).toDouble() * 60 ;
			double seconds = valueText.mid(6, 2).toDouble();
			double miliSecondsFirstDecimal = valueText.mid(9, 1).toDouble() / 10;
			double time = ( hours + minuts + seconds + miliSecondsFirstDecimal) ;
		    positionSample = CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if (numberOfCharater == 11)
		{

			double hours = valueText.mid(0, 2).toDouble() * 3600;
			double minuts = valueText.mid(3, 2).toDouble() * 60;
			double seconds = valueText.mid(6, 2).toDouble();
			double miliSecondsFirstDecimal = valueText.mid(9, 2).toDouble() / 100;
			double time = (hours + minuts + seconds + miliSecondsFirstDecimal);
			positionSample = CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if (numberOfCharater == 12)
		{

			double hours = valueText.mid(0, 2).toDouble() * 3600;
			double minuts = valueText.mid(3, 2).toDouble() * 60;
			double seconds = valueText.mid(6, 2).toDouble();
			double miliSecondsFirstDecimal = valueText.mid(9, 3).toDouble() / 1000;
			double time = (hours + minuts + seconds + miliSecondsFirstDecimal);
			positionSample = CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		return positionSample;
	}
	
}

int ATimerInputBox::ConvertTimeToSamplePositionOperatorD(QString valueText)
{
	if (valueText.isEmpty())
	{
		return 0;
	}
	else
	{
		int numberOfCharater = valueText.count();
		int positionSample = 0;

		if (numberOfCharater == 3)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			positionSample = this->CalculatePositionSampleOnTimePrecition(days, this->Frequency);
		}

		if (numberOfCharater == 4)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			double hours = valueText.mid(3, 1).toDouble() * 3600;
			double time = days + hours;
			positionSample = this->CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if (numberOfCharater == 6)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			double hours = valueText.mid(3, 2).toDouble() * 3600;
			double time = days + hours;
			positionSample = this->CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if (numberOfCharater == 7)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			double hours = valueText.mid(3, 2).toDouble() * 3600;
			double minuts = valueText.mid(6, 2).toDouble() * 60;
			double time =  days + hours + minuts;
			positionSample = this->CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if (numberOfCharater == 9)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			double hours = valueText.mid(3, 2).toDouble() * 3600;
			double minutes = valueText.mid(6, 2).toDouble() * 60;
			double time = days + hours + minutes;
			positionSample = this->CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if(numberOfCharater == 10)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			double hours = valueText.mid(3, 2).toDouble() * 3600;
			double minutes = valueText.mid(6, 2).toDouble() * 60;
			double seconds = valueText.mid(9, 1).toDouble();
			double time = days + hours + minutes + seconds;
			positionSample = this->CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if (numberOfCharater == 12)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			double hours = valueText.mid(3, 2).toDouble() * 3600;
			double minutes = valueText.mid(6, 2).toDouble() * 60;
			double seconds = valueText.mid(9, 2).toDouble();
			double time = days + hours + minutes + seconds;
			positionSample = this->CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if (numberOfCharater == 13)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			double hours = valueText.mid(3, 2).toDouble() * 3600;
			double minuts = valueText.mid(6, 2).toDouble() * 60;
			double seconds = valueText.mid(9, 2).toDouble();
			double miliSecondsFirstDecimal = valueText.mid(12, 1).toDouble() / 10;
			double time = (days + hours + minuts + seconds + miliSecondsFirstDecimal);
			positionSample = this->CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if (numberOfCharater == 14)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			double hours = valueText.mid(3, 2).toDouble() * 3600;
			double minuts = valueText.mid(6, 2).toDouble() * 60;
			double seconds = valueText.mid(9, 2).toDouble();
			double miliSecondsFirstDecimal = valueText.mid(12, 2).toDouble() / 100;
			double time = (days+ hours + minuts + seconds + miliSecondsFirstDecimal);
			positionSample = this->CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}

		if (numberOfCharater == 15)
		{
			double days = valueText.mid(0, 1).toDouble() * 86400;
			double hours = valueText.mid(3, 2).toDouble() * 3600;
			double minuts = valueText.mid(6, 2).toDouble() * 60;
			double seconds = valueText.mid(9, 2).toDouble();
			double miliSecondsFirstDecimal = valueText.mid(12, 3).toDouble() / 1000;
			double time = (days + hours + minuts + seconds + miliSecondsFirstDecimal);
			positionSample = this->CalculatePositionSampleOnTimePrecition(time, this->Frequency);
		}
		

		return positionSample;
	}
}

int ATimerInputBox::CalculatePositionSampleOnTime(int time, double frequency)
{
    return round((time * frequency));
}

int ATimerInputBox::CalculatePositionSampleOnTimePrecition(double time, double frequency)
{
	return round((time * frequency));
}

int ATimerInputBox::CalculatePositionFromSeconds(QString valueText, double frequency)
{
	int position = 0;

	if (!valueText.isEmpty())
	{
		position = valueText.toInt();
        position = round(position * frequency);
	}

	return position;
}

int ATimerInputBox::CalculatePositionFromMinutes(QString valueText, double frequency)
{
	int position = 0;

	if (!valueText.isEmpty())
	{
		position = valueText.toInt();
		position = round( (position * frequency) *60 );
	}

	return position;
}

void ATimerInputBox::SetModelDefault()
{
	this->ModelDefault = true;
	this->ModelHours = false;
	this->ModelMinutes = false;
	this->ModelSeconds = false;
}

void ATimerInputBox::SetModelSeconds()
{
	this->ModelDefault = false;
	this->ModelHours = false;
	this->ModelMinutes = false;
	this->ModelSeconds = true;
}

void ATimerInputBox::SetModelMinutes()
{
	this->ModelDefault = false;
	this->ModelHours = false;
	this->ModelMinutes = true;
	this->ModelSeconds = false;
}

bool ATimerInputBox::VerifyOperatorD(QString valueText)
{
	bool verify = false;

	if (valueText.isEmpty())
		return false;

	if (valueText.contains("d"))
		verify = true;

	return verify;
}
bool ATimerInputBox::VerifyOperatorDote(QString valueText)
{
	bool verify = false;

	if (valueText.isEmpty())
		return false;

	if (valueText.contains("."))
		verify = true;

	return verify;
}

QString ATimerInputBox::ValidateOperator(QString valueText, QKeyEvent* event)
{
	QString str = valueText;

	if ( (valueText.count() == 1) && ( (event->key() == Qt::Key_D) || (event->key() == Qt::Key_Period) )  )
	{
		if ((event->key() == Qt::Key_D))
			str = str + "d";

		if (event->key() == Qt::Key_Period)
			str = str + ".";
	}

	return str;
}

