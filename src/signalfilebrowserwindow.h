#ifndef SIGNALFILEBROWSERWINDOW_H
#define SIGNALFILEBROWSERWINDOW_H

#include "DataModel/infotable.h"
#include <QMainWindow>
#include <functional>
#include <memory>
#include <vector>

#include "AQuestionDialog.h"
#include "ATimerInputBox.h"
#include "ComparatorXML.h"

namespace AlenkaFile {
class DataFile;
class DataModel;

// add by lucas 
class XMLMontageView;
} // namespace AlenkaFile

class Analysis;
class SpikedetAnalysis;
class ModifiedSpikedetAnalysis;
class ClusterAnalysis;
class CenteringClusterAnalysis;
class AutomaticMontage;
class OpenDataFile;
class SignalViewer;
class TrackManager;
class EventManager;
class EventTypeManager;
class MontageManager;
class FilterManager;
class VideoPlayer;
class QComboBox;
class QCheckBox;
class QActionGroup;
class QLabel;
class QAction;
class SyncDialog;
class TableModel;
class DataModelVitness;
class QTimer;
class QUndoStack;
class UndoCommandFactory;
class QPushButton;
class QQuickWidget;
class QStackedWidget;
class QFileInfo;

#pragma region lucas
// Add by lucas 
class ATimerInputBox;
class AQuestionDialog;
class ComparatorXML;
#pragma endregion

/**
 * @brief This class implements the top level window of the program.
 */
class SignalFileBrowserWindow : public QMainWindow {
  Q_OBJECT

  std::unique_ptr<OpenDataFile> openDataFile;
  SignalViewer *signalViewer;
  QQuickWidget *view;
  TrackManager *trackManager;
  EventManager *eventManager;
  EventTypeManager *eventTypeManager;
  MontageManager *montageManager;
  FilterManager *filterManager;
  VideoPlayer *videoPlayer;
  QComboBox *lowpassComboBox;
  QComboBox *highpassComboBox;
  QCheckBox *notchCheckBox;
  QComboBox *montageComboBox;
  QComboBox *eventTypeComboBox;
  QComboBox *resolutionComboBox;
  QComboBox *unitsComboBox;
  QActionGroup *timeModeActionGroup;
  QActionGroup *timeLineIntervalActionGroup;
  QAction *setTimeLineIntervalAction;
  QLabel *timeModeStatusLabel;
  QLabel *timeStatusLabel;
  QLabel *positionStatusLabel;
  QLabel *cursorStatusLabel;
  double spikeDuration;
  std::vector<std::unique_ptr<Analysis>> signalAnalysis;
  SpikedetAnalysis *spikedetAnalysis;
  ModifiedSpikedetAnalysis *modifiedSpikedetAnalysis;
  ClusterAnalysis *clusterAnalysis;
  CenteringClusterAnalysis *centeringClusterAnalysis;
  std::vector<QAction *> analysisActions;
  SyncDialog *syncDialog;
  QAction *synchronize;
  std::vector<QMetaObject::Connection> openFileConnections;
  std::vector<QMetaObject::Connection> managersConnections;
  QTimer *autoSaveTimer;
  std::string autoSaveName;
  QUndoStack *undoStack;
  QAction *saveFileAction;
  QAction *closeFileAction;
  QAction *exportToEdfAction;
  bool allowSaveOnClean;
  QPushButton *switchButton;
  QByteArray windowState, windowGeometry;
  QStackedWidget *stackedWidget;
  const int COMBO_PRECISION = 2, RECENT_FILE_COUNT = 10;
  int nameIndex = 0;
  QMenu *fileMenu;
  std::vector<QAction *> recentFilesActions;
  std::vector<std::unique_ptr<AutomaticMontage>> autoMontages;

  struct OpenFileResources {
    std::unique_ptr<AlenkaFile::DataFile> file;
    std::unique_ptr<AlenkaFile::DataModel> dataModel;
    std::unique_ptr<UndoCommandFactory> undoFactory;

    std::unique_ptr<TableModel> eventTypeTable;
    std::unique_ptr<TableModel> montageTable;
    std::unique_ptr<TableModel> eventTable;
    std::unique_ptr<TableModel> trackTable;
  };
  std::unique_ptr<OpenFileResources> fileResources;

#pragma region MyRegion
  // Add by lucas 
  ATimerInputBox* Position;
  ATimerInputBox* CursorTime;
  // Dialog box
  AQuestionDialog* QuestionBox;
  ComparatorXML* XMLComparator;
#pragma endregion

public:
  explicit SignalFileBrowserWindow(QWidget *parent = nullptr);
  ~SignalFileBrowserWindow() override;

  void openCommandLineFile();

  static QDateTime sampleToDate(AlenkaFile::DataFile *file, int sample);
  static QDateTime sampleToOffset(AlenkaFile::DataFile *file, int sample);
  static QString
  sampleToDateTimeString(AlenkaFile::DataFile *file, int sample,
                         InfoTable::TimeMode mode = InfoTable::TimeMode::size);
  static std::unique_ptr<AlenkaFile::DataFile>
  dataFileBySuffix(const QString &fileName,
                   const std::vector<std::string> &additionalFiles,
                   QWidget *parent = nullptr);
  static int askForDataFileBackend(const QStringList &items,
                                   QWidget *parent = nullptr);

protected:
  void closeEvent(QCloseEvent *event) override;
  void keyPressEvent(QKeyEvent *event) override;

private:
  std::vector<QMetaObject::Connection>
  connectVitness(const DataModelVitness *vitness, std::function<void()> f);
  void mode(int m);
  void deleteAutoSave();
  void setCurrentInNumericCombo(QComboBox *combo, double value);
  void sortInLastItem(QComboBox *combo);
  QString imageFilePathDialog();
  void setSecondsPerPage(double seconds);
  void createDefaultMontage();
  void addRecentFilesActions();
  void updateRecentFiles(const QFileInfo &fileInfo);
  void addAutoMontage(AutomaticMontage *autoMontage);

#pragma region Lucas
 // Properties
  // @Brief this properties are used to create the process of mantain the montage 
  bool Provision;
  string OldPath; // path the first storage data 
  string NewPath; //  path of we want compare
  // Methods
  QString ConvertPositionToSeconds(int positionSmaple); // Method to do the corvertion on times to seconds
  QString ConvertPositionToMinutes(int positionSmaple); // Method to do the corvetion of times to minutes
  void ProvisionFile(string path); // Method to identif 
#pragma endregion

private slots:
  void openFile();
  void openFile(const QString &fileName,const std::vector<std::string> &additionalFiles = std::vector<std::string>());
  bool closeFile();
  void saveFile();
  void exportToEdf();
  void lowpassComboBoxUpdate(const QString &text);
  void lowpassComboBoxUpdate(bool on);
  void lowpassComboBoxUpdate(double value);
  void highpassComboBoxUpdate(const QString &text);
  void highpassComboBoxUpdate(bool on);
  void highpassComboBoxUpdate(double value);
  void resolutionComboBoxUpdate(const QString &text);
  void resolutionComboBoxUpdate(float value);
  void updateManagers(int value);
  void updateTimeMode(InfoTable::TimeMode mode);
  void updatePositionStatusLabel();
  void updateCursorStatusLabel();
  void updateMontageComboBox();
  void updateEventTypeComboBox();
  void runSignalAnalysis(int i);
  void cleanChanged(bool clean);
  void closeFilePropagate();
  void setEnableFileActions(bool enable);
  void setFilePathInQML();
  void switchToAlenka();
  void verticalZoomIn();
  void verticalZoomOut();
  void exportDialog();

#pragma region Lucas
  // Add by lucas
  void UpadateCursorTimeInputBox();
  void UpadatePositionTimeInputBox();
  void UpdateInputBox(ATimerInputBox* timeBox, ATimerInputBox::ModelInput modelTime);
  void ChangedTimeModel(int model); // Changes the time model 
  void UpdateTracksResult(); // Update the tracks witn result
  void UpadateEventsResult(); // Update the events in track manager with result
  void UpdateTracksComparable(); // update the track manger with the loads
  void UpadateEventsComparable(); // update the track manger with the loads
#pragma endregion
};

#endif // SIGNALFILEBROWSERWINDOW_H
