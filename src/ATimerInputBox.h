#ifndef ATIMERINPUTBOX_H
#define ATIMERINPUTBOX_H

#include "ATimerDialog.h"
#include "ARealDialog.h"

#include <qlineedit.h>
#include <qdatetime.h>

class ATimerInputBox : public QLineEdit {

    Q_OBJECT

public:
	// Enums
	enum TypeTime { Position, Cursor };
	enum ModelInput { Sample, Ofset, Real };

	// Methods
	ATimerInputBox();
	void SetModel(ModelInput typeModel);
	void ChangeToPositionType();
	void DefineFrequency(double frequency);

	bool GetModelHours() { return ModelHours; }
	bool GetModelMinutes() { return ModelMinutes; }
	bool GetModelSeconds() { return ModelSeconds; }
	bool GetModelDefault() { return ModelDefault; }

signals:
	void ChangedBaseModel(int model);

protected:
	// Events
	void mousePressEvent(QMouseEvent* event);
	void keyPressEvent(QKeyEvent* event);

private:
	// Properties
	ATimerDialog* TimerDialog;
	ARealDialog* RealDialog;
	TypeTime Type;
	ModelInput Model;
	double Frequency;
	int TotalTime;
	int TotalSmaple;
	QDate StartTime;
	int IntervalHours;
	int IntervalMinuts;
	int IntervalSeconds;
	int TotalHours;
	int TotalMinuts;
	int TotalSeconds;
	bool ModelHours;
	bool ModelMinutes;
	bool ModelSeconds;
	bool ModelDefault;

	// Methods
	void OpenTimerDialog();
	int CoverterSampleToInt(QString valueText);
	int ConvertTimeToSamplePosition(QString valueText);
	int ConvertTimeToSamplePositionOperatorD(QString valueText);
	int CalculatePositionSampleOnTime(int time, double frequency);
	int CalculatePositionSampleOnTimePrecition(double time, double frequency);
	// Calculates time per position
	int CalculatePositionFromSeconds(QString valueText, double frequency);
	int CalculatePositionFromMinutes(QString valueText, double frequency);

	// Define times modes
	void SetModelDefault();
	void SetModelSeconds();
	void SetModelMinutes();

	// Defines operator
	bool VerifyOperatorD(QString valueText);
	bool VerifyOperatorDote(QString valueText);
	QString ValidateOperator(QString valueText, QKeyEvent* event);
};
#endif
