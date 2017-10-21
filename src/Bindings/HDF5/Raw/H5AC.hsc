module Bindings.HDF5.Raw.H5AC where
#include <bindings.h>
#include <H5ACpublic.h>

#strict_import

import Bindings.HDF5.Raw.H5
import Bindings.HDF5.Raw.H5C

-- |'H5AC_cache_config_t' is a public structure intended for use in public APIs.
-- At least in its initial incarnation, it is basicaly a copy of struct
-- 'H5C_auto_size_ctl_t', minus the 'report_fcn' field, and plus the
-- 'dirty_bytes_threshold' field.
--
-- The 'report_fcn' field is omitted, as including it would require us to
-- make 'H5C_t' structure public.
--
-- The 'dirty_bytes_threshold' field does not appear in 'H5C_auto_size_ctl_t',
-- as synchronization between caches on different processes is handled at
-- the H5AC level, not at the level of H5C.  Note however that there is
-- considerable interaction between this value and the other fields in this
-- structure.
--
-- Similarly, the 'open_trace_file', 'close_trace_file', and 'trace_file_name'
-- fields do not appear in 'H5C_auto_size_ctl_t', as most trace file
-- issues are handled at the H5AC level.  The one exception is storage of
-- the pointer to the trace file, which is handled by H5C.
--
-- The structure is in H5ACpublic.h as we may wish to allow different
-- configuration options for metadata and raw data caches.
--
-- The fields of the structure are discussed individually below.
-- 
#starttype H5AC_cache_config_t

-- |Integer field containing the version number of this version
-- of the H5AC_cache_config_t structure.  Any instance of
-- H5AC_cache_config_t passed to the cache must have a known
-- version number, or an error will be flagged.
#field version,                 CInt

-- |Boolean field used to enable and disable the default
-- reporting function.  This function is invoked every time the
-- automatic cache resize code is run, and reports on its activities.
-- 
-- This is a debugging function, and should normally be turned off.
#field rpt_fcn_enabled,         <hbool_t>

-- |Boolean field indicating whether the trace_file_name
-- field should be used to open a trace file for the cache.
-- 
-- The trace file is a debuging feature that allow the capture of
-- top level metadata cache requests for purposes of debugging and/or
-- optimization.  This field should normally be set to FALSE, as
-- trace file collection imposes considerable overhead.
-- 
-- This field should only be set to TRUE when the trace_file_name
-- contains the full path of the desired trace file, and either
-- there is no open trace file on the cache, or the close_trace_file
-- field is also TRUE.
#field open_trace_file,         <hbool_t>

-- |Boolean field indicating whether the current trace
-- file (if any) should be closed.
-- 
-- See the above comments on the open_trace_file field.  This field
-- should be set to FALSE unless there is an open trace file on the
-- cache that you wish to close.
#field close_trace_file,        <hbool_t>

-- |Full path of the trace file to be opened if the 'open_trace_file' field is TRUE.
-- 
-- In the parallel case, an ascii representation of the mpi rank of
-- the process will be appended to the file name to yield a unique
-- trace file name for each process.
-- 
-- The length of the path must not exceed 'h5ac__MAX_TRACE_FILE_NAME_LEN'
-- characters.
#array_field trace_file_name,   CChar

-- |Boolean field used to either report the current
-- evictions enabled status of the cache, or to set the cache's
-- evictions enabled status.
-- 
-- In general, the metadata cache should always be allowed to
-- evict entries.  However, in some cases it is advantageous to
-- disable evictions briefly, and thereby postpone metadata
-- writes.  However, this must be done with care, as the cache
-- can grow quickly.  If you do this, re-enable evictions as
-- soon as possible and monitor cache size.
-- 
-- At present, evictions can only be disabled if automatic
-- cache resizing is also disabled (that is, @( 'incr_mode' ==
-- 'h5c_incr__off' ) && ( 'decr_mode' == 'h5c_decr__off' )@).  There
-- is no logical reason why this should be so, but it simplifies
-- implementation and testing, and I can't think of any reason
-- why it would be desireable.  If you can think of one, I'll
-- revisit the issue.
#field evictions_enabled,       <hbool_t>

-- |Boolean flag indicating whether the size of the
-- initial size of the cache is to be set to the value given in
-- the initial_size field.  If 'set_initial_size' is FALSE, the
-- 'initial_size' field is ignored.
#field set_initial_size,        <hbool_t>

-- |If enabled, this field contain the size the cache is
-- to be set to upon receipt of this structure.  Needless to say,
-- 'initial_size' must lie in the closed interval @['min_size' .. 'max_size']@.
#field initial_size,            <size_t>

-- |double in the range 0 to 1 indicating the fraction
-- of the cache that is to be kept clean.  This field is only used
-- in parallel mode.  Typical values are 0.1 to 0.5.
#field min_clean_fraction,      CDouble

-- TODO: figure out where MIN_MAX_CACHE_SIZE and MAX_MAX_CACHE_SIZE come from.  They don't seem to be in any public headers
-- |Maximum size to which the cache can be adjusted.  The
-- supplied value must fall in the closed interval
-- @['MIN_MAX_CACHE_SIZE' .. 'MAX_MAX_CACHE_SIZE']@.  Also, 'max_size' must
-- be greater than or equal to 'min_size'.
#field max_size,                <size_t>

-- TODO: figure out where H5C__MIN_MAX_CACHE_SIZE and H5C__MAX_MAX_CACHE_SIZE come from.  They don't seem to be in any public headers
-- |Minimum size to which the cache can be adjusted.  The
-- supplied value must fall in the closed interval
-- @['H5C__MIN_MAX_CACHE_SIZE' .. 'H5C__MAX_MAX_CACHE_SIZE']@.  Also, 'min_size'
-- must be less than or equal to 'max_size'.
#field min_size,                <size_t>

-- TODO: figure out where H5C__MIN_AR_EPOCH_LENGTH and H5C__MAX_AR_EPOCH_LENGTH come from.  They don't seem to be in any public headers
-- |Number of accesses on the cache over which to collect
-- hit rate stats before running the automatic cache resize code,
-- if it is enabled.
-- 
-- At the end of an epoch, we discard prior hit rate data and start
-- collecting afresh.  The epoch_length must lie in the closed
-- interval @['H5C__MIN_AR_EPOCH_LENGTH' .. 'H5C__MAX_AR_EPOCH_LENGTH']@.
#field epoch_length,            CLong

-- |Instance of the 'H5C_cache_incr_mode' enumerated type whose
-- value indicates how we determine whether the cache size should be
-- increased.  At present there are two possible values:
-- 
-- * 'h5c_incr__off':
--         Don't attempt to increase the size of the cache
--         automatically.
--         When this increment mode is selected, the remaining fields
--         in the cache size increase section ar ignored.
-- 
-- * 'h5c_incr__threshold':
--         Attempt to increase the size of the cache
--         whenever the average hit rate over the last epoch drops
--         below the value supplied in the lower_hr_threshold
--         field.
--         Note that this attempt will fail if the cache is already
--         at its maximum size, or if the cache is not already using
--         all available space.
-- 
-- Note that you must set 'decr_mode' to 'h5c_incr__off' if you
-- disable metadata cache entry evictions.
#field incr_mode,               <H5C_cache_incr_mode>

-- |Lower hit rate threshold.  If the increment mode
-- ('incr_mode') is 'h5c_incr__threshold' and the hit rate drops below the
-- value supplied in this field in an epoch, increment the cache size by
-- 'size_increment'.  Note that cache size may not be incremented above
-- 'max_size', and that the increment may be further restricted by the
-- 'max_increment' field if it is enabled.
-- 
-- When enabled, this field must contain a value in the range [0.0, 1.0].
-- Depending on the 'incr_mode' selected, it may also have to be less than
-- 'upper_hr_threshold'.
#field lower_hr_threshold,      CDouble

-- |Double containing the multiplier used to derive the new
-- cache size from the old if a cache size increment is triggered.
-- The increment must be greater than 1.0, and should not exceed 2.0.
-- 
-- The new cache size is obtained my multiplying the current max cache
-- size by the increment, and then clamping to max_size and to stay
-- within the max_increment as necessary.
#field increment,               CDouble

-- |Boolean flag indicating whether the max_increment
-- field should be used to limit the maximum cache size increment.
#field apply_max_increment,     <hbool_t>

-- |If enabled by the 'apply_max_increment' field described
-- above, this field contains the maximum number of bytes by which the
-- cache size can be increased in a single re-size.
#field max_increment,           <size_t>

-- |Instance of the 'H5C_cache_flash_incr_mode' enumerated
-- type whose value indicates whether and by which algorithm we should
-- make flash increases in the size of the cache to accomodate insertion
-- of large entries and large increases in the size of a single entry.
-- 
-- The addition of the flash increment mode was occasioned by performance
-- problems that appear when a local heap is increased to a size in excess
-- of the current cache size.  While the existing re-size code dealt with
-- this eventually, performance was very bad for the remainder of the
-- epoch.
-- 
-- At present, there are two possible values for the 'flash_incr_mode':
-- 
-- * 'h5c_flash_incr__off':  Don't perform flash increases in the size of
--         the cache.
-- 
-- * 'h5c_flash_incr__add_space':  Let @x@ be either the size of a newly
--         newly inserted entry, or the number of bytes by which the
--         size of an existing entry has been increased.
--         If @x > flash_threshold * current max cache size@,
--         increase the current maximum cache size by @x * flash_multiple@
--         less any free space in the cache, and start a new epoch.  For
--         now at least, pay no attention to the maximum increment.
-- 
-- In both of the above cases, the flash increment pays no attention to
-- the maximum increment (at least in this first incarnation), but DOES
-- stay within 'max_size'.
-- 
-- With a little thought, it should be obvious that the above flash
-- cache size increase algorithm is not sufficient for all circumstances.
-- For example, suppose the user round robins through
-- @(1/flash_threshold) + 1@ groups, adding one data set to each on each
-- pass.  Then all will increase in size at about the same time, requiring
-- the max cache size to at least double to maintain acceptable
-- performance, however the above flash increment algorithm will not be
-- triggered.
-- 
-- Hopefully, the add space algorithms detailed above will be sufficient
-- for the performance problems encountered to date.  However, we should
-- expect to revisit the issue.
#field flash_incr_mode,         <H5C_cache_flash_incr_mode>

-- |Double containing the multiple described above in the
-- 'h5c_flash_incr__add_space' section of the discussion of the
-- 'flash_incr_mode' section.  This field is ignored unless 'flash_incr_mode'
-- is 'h5c_flash_incr__add_space'.
#field flash_multiple,          CDouble

-- |Double containing the factor by which current max cache
-- size is multiplied to obtain the size threshold for the 'add_space' flash
-- increment algorithm.  The field is ignored unless 'flash_incr_mode' is
-- 'h5c_flash_incr__add_space'.
#field flash_threshold,         CDouble

-- |Instance of the 'H5C_cache_decr_mode' enumerated type whose
-- value indicates how we determine whether the cache size should be
-- decreased.  At present there are four possibilities.
-- 
-- * 'h5c_decr__off':  Don't attempt to decrease the size of the cache
--         automatically. When this increment mode is selected, the remaining
--         fields in the cache size decrease section are ignored.
-- 
-- * 'h5c_decr__threshold': Attempt to decrease the size of the cache
--         whenever the average hit rate over the last epoch rises
--         above the value supplied in the upper_hr_threshold
--         field.
-- 
-- * 'h5c_decr__age_out':  At the end of each epoch, search the cache for
--         entries that have not been accessed for at least the number
--         of epochs specified in the 'epochs_before_eviction' field, and
--         evict these entries.  Conceptually, the maximum cache size
--         is then decreased to match the new actual cache size.  However,
--         this reduction may be modified by the 'min_size', the
--         'max_decrement', and/or the 'empty_reserve'.
-- 
-- * 'h5c_decr__age_out_with_threshold':  Same as 'age_out', but we only
--         attempt to reduce the cache size when the hit rate observed
--         over the last epoch exceeds the value provided in the
--         'upper_hr_threshold' field.
-- 
-- Note that you must set 'decr_mode' to 'h5c_decr__off' if you
-- disable metadata cache entry evictions.
#field decr_mode,               <H5C_cache_decr_mode>

-- |Upper hit rate threshold.  The use of this field varies according to
-- the current 'decr_mode':
-- 
-- * 'h5c_decr__off' or 'h5c_decr__age_out':  The value of this field is
--         ignored.
-- 
-- * 'h5c_decr__threshold':  If the hit rate exceeds this threshold in any
--         epoch, attempt to decrement the cache size by 'size_decrement'.
-- 
--         Note that cache size may not be decremented below 'min_size'.
-- 
--         Note also that if the 'upper_threshold' is 1.0, the cache size
--         will never be reduced.
-- 
-- * 'h5c_decr__age_out_with_threshold':  If the hit rate exceeds this
--         threshold in any epoch, attempt to reduce the cache size
--         by evicting entries that have not been accessed for more
--         than the specified number of epochs.
#field upper_hr_threshold,      CDouble

-- |This field is only used when the decr_mode is 'h5c_decr__threshold'.
--
-- The field is a double containing the multiplier used to derive the
-- new cache size from the old if a cache size decrement is triggered.
-- The decrement must be in the range 0.0 (in which case the cache will
-- try to contract to its minimum size) to 1.0 (in which case the
-- cache will never shrink).
#field decrement,               CDouble

-- |Boolean flag used to determine whether decrements
-- in cache size are to be limited by the 'max_decrement' field.
#field apply_max_decrement,     <hbool_t>

-- |Maximum number of bytes by which the cache size can be
-- decreased in a single re-size.  Note that decrements may also be
-- restricted by the min_size of the cache, and (in age out modes) by
-- the 'empty_reserve' field.
#field max_decrement,           <size_t>

-- TODO: figure out where H5C__MAX_EPOCH_MARKERS comes from
-- |Integer field used in H5C_decr__age_out and
-- 'h5c_decr__age_out_with_threshold' decrement modes.
-- 
-- This field contains the number of epochs an entry must remain
-- unaccessed before it is evicted in an attempt to reduce the
-- cache size.  If applicable, this field must lie in the range
-- @[1 .. 'H5C__MAX_EPOCH_MARKERS']@.
#field epochs_before_eviction,  CInt

-- |Boolean field controlling whether the 'empty_reserve'
-- field is to be used in computing the new cache size when the
-- 'decr_mode' is 'h5c_decr__age_out' or 'h5c_decr__age_out_with_threshold'.
#field apply_empty_reserve,     <hbool_t>

-- |To avoid a constant racheting down of cache size by small
-- amounts in the 'h5c_decr__age_out' and 'h5c_decr__age_out_with_threshold'
-- modes, this field allows one to require that any cache size
-- reductions leave the specified fraction of unused space in the cache.
-- 
-- The value of this field must be in the range [0.0, 1.0].  I would
-- expect typical values to be in the range of 0.01 to 0.1.
#field empty_reserve,           CDouble

-- |Threshold of dirty byte creation used to
-- synchronize updates between caches. (See above for outline and
-- motivation.)
-- 
-- This value MUST be consistant across all processes accessing the
-- file.  This field is ignored unless HDF5 has been compiled for
-- parallel.
#field dirty_bytes_threshold,   CInt

#if H5_VERSION_GE(1,8,6)
-- |Integer field containing a code indicating the
-- desired metadata write strategy.  The valid values of this field
-- are enumerated and discussed below:
#field metadata_write_strategy, CInt
#endif

#stoptype

#num H5AC__CURR_CACHE_CONFIG_VERSION
#num H5AC__MAX_TRACE_FILE_NAME_LEN

#if H5_VERSION_GE(1,8,6)

-- |When 'metadata_write_strategy' is set to this value, only process 
-- zero is allowed to write dirty metadata to disk.  All other 
-- processes must retain dirty metadata until they are informed at
-- a sync point that the dirty metadata in question has been written
-- to disk.
-- 
-- When the sync point is reached (or when there is a user generated
-- flush), process zero flushes sufficient entries to bring it into
-- complience with its min clean size (or flushes all dirty entries in
-- the case of a user generated flush), broad casts the list of 
-- entries just cleaned to all the other processes, and then exits
-- the sync point.
-- 
-- Upon receipt of the broadcast, the other processes mark the indicated
-- entries as clean, and leave the sync point as well.
#num H5AC_METADATA_WRITE_STRATEGY__PROCESS_0_ONLY

-- |In the distributed metadata write strategy, process zero still makes
-- the decisions as to what entries should be flushed, but the actual 
-- flushes are distributed across the processes in the computation to 
-- the extent possible.
-- 
-- In this strategy, when a sync point is triggered (either by dirty
-- metadata creation or manual flush), all processes enter a barrier.
-- 
-- On the other side of the barrier, process 0 constructs an ordered
-- list of the entries to be flushed, and then broadcasts this list
-- to the caches in all the processes.
-- 
-- All processes then scan the list of entries to be flushed, flushing
-- some, and marking the rest as clean.  The algorithm for this purpose
-- ensures that each entry in the list is flushed exactly once, and 
-- all are marked clean in each cache.
-- 
-- Note that in the case of a flush of the cache, no message passing
-- is necessary, as all processes have the same list of dirty entries, 
-- and all of these entries must be flushed.  Thus in this case it is 
-- sufficient for each process to sort its list of dirty entries after 
-- leaving the initial barrier, and use this list as if it had been 
-- received from process zero.
-- 
-- To avoid possible messages from the past/future, all caches must
-- wait until all caches are done before leaving the sync point.
#num H5AC_METADATA_WRITE_STRATEGY__DISTRIBUTED

#endif